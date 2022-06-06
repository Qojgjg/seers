
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Float "mo:base/Float";
import Array "mo:base/Array";

import Utils "Utils";
import Forecast "Forecast";
import Tokens "Tokens";
import Comment "Comment";

module {
    public type MarketState = {
        #any;
        #pending;
        #approved;
        #open;
        #closed;
        #invalid;
        #resolved: Nat;
    };

    public type MarketCategory = {
        #any;
        #crypto;
        #science;
        #politics;
        #sports;
        #entertainment;
        #business;
        #financial;
        #seers;
        #dfinity;
        #self;
    };

    public type MarketInitData = {
        id: Nat32;
        title: Text;
        description: Text;
        labels: [Text];
        images: [Text];
        probabilities: [Float];
        category: MarketCategory;
        collateralType: Tokens.CollateralType;
        liquidity: Float;
        startDate: Time.Time;
        endDate: Time.Time;
        imageUrl: Text;
        author: Text;
    };

    public type HistPoint = {
        probabilities: [Float];
        liquidity: Float;
        createdAt: Time.Time;
    };

    public class Market (initData: MarketInitData) = this {
        public var id: Nat32 = initData.id;    
        public var title: Text = initData.title;
        public var description: Text = initData.description;
        public var startDate: Time.Time = initData.startDate;
        public var endDate: Time.Time = initData.endDate;
        public var author: Text = initData.author;
        public var labels: [Text] = initData.labels;
        public var images: [Text] = initData.images;
        public var category: MarketCategory = initData.category;
        public var collateralType: Tokens.CollateralType = initData.collateralType;
        public var probabilities: [Float] = initData.probabilities;
        public var liquidity: Float = initData.liquidity;
        public var reserves: [Float] = do {
            let size = initData.labels.size();
            var reserves: [Float] = [];
            for (i in Iter.range(0, size - 1)) {
                reserves := Array.append(reserves, [initData.liquidity]);
            };
            reserves
        };
        public var k: Float = do {
            let size = initData.labels.size();
            var k: Float = 1.0;
            for (i in Iter.range(0, size - 1)) {
                k := k * reserves[i];
            };
            k
        };
        public var providers: Buffer.Buffer<Text> = do {
            var providers = Buffer.Buffer<Text>(1);
            providers.add(initData.author);
            providers
        };
        public var bettors: Buffer.Buffer<Text> = Buffer.Buffer<Text>(10);
        public var totalShares: Float = Float.sqrt(k);
        public var imageUrl: Text = initData.imageUrl;
        public var state: MarketState = #open;
        public var volume: Float = 0.0;
        public var comments: Buffer.Buffer<Comment.Comment> = Buffer.Buffer<Comment.Comment>(10);
        public var histPrices: Buffer.Buffer<HistPoint> = do {
            var histPrices = Buffer.Buffer<HistPoint>(1);
            let histPoint: HistPoint = {
                probabilities = initData.probabilities;
                liquidity = initData.liquidity;
                createdAt = Time.now();
            };
            histPrices.add(histPoint);
            histPrices
        };
        public var forecasts: Buffer.Buffer<Forecast.Forecast> = Buffer.Buffer<Forecast.Forecast>(5);
        public var createdAt: Time.Time = Time.now();
        public var modifiedAt: Time.Time = Time.now();

        public func freeze(): MarketStable {
            let stableComments = Array.map(comments.toArray(), func (c: Comment.Comment): Comment.CommentStable {
                c.freeze()
            });
            let ms: MarketStable = {
                id = id;    
                title = title;
                description = description;
                startDate = startDate;
                endDate = endDate;
                author = author;
                labels = labels;
                images = images;
                probabilities = probabilities;
                liquidity = liquidity;
                reserves = reserves;
                category = category;
                collateralType = collateralType;
                k = k;
                providers = providers.toArray();
                bettors = bettors.toArray();
                totalShares = totalShares;
                imageUrl = imageUrl;
                state = state;
                volume = volume;
                comments = stableComments;
                histPrices = histPrices.toArray();
                forecasts = forecasts.toArray();
                createdAt = createdAt;
                modifiedAt = modifiedAt;
            };
            return ms;
        }
    };
    public type MarketStable = {
        id: Nat32;    
        title: Text;
        description: Text;
        startDate: Time.Time;
        endDate: Time.Time;
        author: Text;
        labels: [Text];
        images: [Text];
        probabilities: [Float];
        liquidity: Float;
        reserves: [Float];
        category: MarketCategory;
        collateralType: Tokens.CollateralType;
        k: Float;
        providers: [Text];
        bettors: [Text];
        totalShares: Float;
        imageUrl: Text;
        state: MarketState;
        volume: Float;
        comments: [Comment.CommentStable];
        histPrices: [HistPoint];
        forecasts: [Forecast.Forecast];
        createdAt: Time.Time;
        modifiedAt: Time.Time;
    };

    public func unFreeze(m: MarketStable): Market {
        let initData: MarketInitData = {
            id = m.id;
            title = m.title;
            description = m.description;
            startDate = m.startDate;
            endDate = m.endDate;
            author = m.author;
            labels = m.labels;
            images = m.images;
            probabilities = m.probabilities;
            liquidity = m.liquidity;
            imageUrl = m.imageUrl;
            category = m.category;
            collateralType = m.collateralType;
        };
        let comments = Array.map(m.comments, func (c: Comment.CommentStable): Comment.Comment {
            Comment.unFreeze(c)
        });
        var market: Market = Market(initData);
        market.reserves := m.reserves;
        market.k := m.k;
        market.providers := Utils.bufferFromArray(m.providers);
        market.bettors := Utils.bufferFromArray(m.bettors);
        market.totalShares := m.totalShares;
        market.state := m.state;
        market.volume := m.volume;
        market.comments := Utils.bufferFromArray(comments);
        market.histPrices := Utils.bufferFromArray(m.histPrices);
        market.forecasts := Utils.bufferFromArray(m.forecasts);
        market.createdAt := m.createdAt;
        market.modifiedAt := m.modifiedAt;

        return market;
    };
}