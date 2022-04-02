import Map "mo:base/HashMap";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Int "mo:base/Int";
import Float "mo:base/Float";
import List "mo:base/List";
import Trie "mo:base/Trie";
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import Option "mo:base/Option";
import Array "mo:base/Array";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Result "mo:base/Result";

shared({ caller = initializer }) actor class Market() {
    /* Types */

    public type Title = Text;
    public type Description = Text;
    public type Url = Text;
    public type Author = Text;
    public type MarketId = Nat32;
    public type UserId = Text;
    public type Shares = Int;
    public type Probability = Float;
    public type Balance = Float;

    public type MarketState = {
        #pending: ();
        #open: ();
        #closed: ();
        #resolved: Nat;
    };

    public type UserMarket = {
        marketId: MarketId;
        marketTitle: Title;
        balances: [Balance];
        shares: Shares;
    };

    public type User = {
        var id: UserId; // Principal.
        var handle: Text;
        var seerBalance: Balance;
        var expSeerBalance: Balance;
        var markets: [UserMarket];
    };

    public type UserResult = {
        id: UserId; // Principal.
        handle: Text;
        seerBalance: Balance;
        expSeerBalance: Balance;
        markets: [UserMarket];
    };

    public type MarketInitData = {
        title: Title;
        description: Description;
        labels: [Text];
        images: [Text];
        liquidity: Balance;
        endDate: Time.Time;
        imageUrl: Url;
    };

    public type Comment = {
        author: Text; // handle.
        content: Text;
    };

    public type Market = {
        id: MarketId;    
        title: Title;
        description: Description;
        startDate: Time.Time;
        endDate: Time.Time;
        author: Author;
        labels: [Text];
        images: [Text];
        var probabilities: [Probability];
        var liquidity: Balance;
        var reserves: [Balance];
        var k: Balance;
        var providers: [Text]; // list of principals
        var blockTimestampLast: Time.Time;
        var totalShares: Shares;
        var imageUrl: Url;
        var state: MarketState;
        var volume: Balance;
        var comments: [Comment];
    };

    public type MarketResult = {
        id: MarketId;    
        title: Title;
        description: Description;
        startDate: Time.Time;
        endDate: Time.Time;
        author: Author;
        labels: [Text];
        images: [Text];
        probabilities: [Probability];
        liquidity: Balance;
        reserves: [Balance];
        k: Balance;
        providers: [Text]; // list of principals
        blockTimestampLast: Time.Time;
        totalShares: Shares;
        imageUrl: Url;
        state: MarketState;
        volume: Balance;
        comments: [Comment];
    };  

    /* State */
    
    private stable var nextMarketId: MarketId = 0;
    private stable var handles: Trie.Trie<Text, UserId> = Trie.empty();
    
    stable var stableUsers: [(UserId, UserResult)] = [];
    stable var stableMarkets: [(MarketId, MarketResult)] = [];


    private func userResultToUser(u: UserResult): User {
        let user = {
            var id = u.id;
            var handle = u.handle;
            var seerBalance = u.seerBalance;
            var expSeerBalance = u.expSeerBalance;
            var markets = u.markets;
        };
        return user;
    };

    private func userToUserResult(u: User): UserResult {
        let userResult = {
            id = u.id;
            handle = u.handle;
            seerBalance = u.seerBalance;
            expSeerBalance = u.expSeerBalance;
            markets = u.markets;
        };
        return userResult;
    };


    private func marketResultToMarket(m: MarketResult): Market {
        let market = {
            id = m.id;    
            title = m.title;
            description = m.description;
            startDate = m.startDate;
            endDate = m.endDate;
            author = m.author;
            labels = m.labels;
            images = m.images;
            var probabilities = m.probabilities;
            var liquidity = m.liquidity;
            var reserves = m.reserves;
            var k = m.k;
            var blockTimestampLast = m.blockTimestampLast;
            var totalShares = m.totalShares;
            var providers = m.providers;
            var imageUrl = m.imageUrl;
            var state = m.state;
            var volume = m.volume;
            var comments = m.comments;
        };

        return market;
    };

    private func marketToMarketResult(m: Market): MarketResult {
        let market = {
            id = m.id;    
            title = m.title;
            description = m.description;
            labels = m.labels;
            images = m.images;
            probabilities = m.probabilities;
            liquidity = m.liquidity;
            reserves = m.reserves;
            k = m.k;
            startDate = m.startDate;
            endDate = m.endDate;
            author = m.author;
            blockTimestampLast = m.blockTimestampLast;
            totalShares = m.totalShares;
            providers = m.providers;
            imageUrl = m.imageUrl;
            state = m.state;
            volume = m.volume;
            comments = m.comments;
        };
        return market;    
    };

    private var userMap = do {
        let u0: UserResult = {
            id = "gt5em-5sb4t-2hqzi-mzi2a-7eup4-7ja4x-r7uhb-lap7m-f7tuy-meoyj-oae";
            seerBalance = 1000;
            expSeerBalance = 1000;
            markets = [];
            handle = "omsiva";
        };

        let u1: UserResult = {
            id = "op2gv-bsww4-xbrzq-a7hyb-574a5-ajwkv-6jzdo-ajlid-taqht-rh6vk-cqe";
            seerBalance = 3000;
            expSeerBalance = 3000;
            markets = [];
            handle = "zantchinz.icp";
        };

        let u2: UserResult = {
            id = "mk7oe-zv3sn-7kzi2-x7z3q-n2ril-mnwtt-epeib-eonvh-cfhna-4wpif-4qe";   
            seerBalance = 3000;
            expSeerBalance = 3000;
            markets = [];
            handle = "Quy_NCA97";
        };

        let u3: UserResult = {
            id = "ymbga-tid7w-gbcp6-u7pff-7ffin-ga2hb-yuhyg-fcdjk-bfm46-4skqv-hae";   
            seerBalance = 3000;
            expSeerBalance = 3000;
            markets = [];
            handle = "Krim";
        };


        let u4: UserResult = {
            id = "5wihw-3ikug-zgmlg-ebgi7-cwidg-w3fma-wvsv4-xdpl4-olwii-emcvk-uqe";
            seerBalance = 1000;
            expSeerBalance = 1000;
            markets = []; 
            handle = "flatdefi";
        };

        let u5: UserResult = {
            id = "7msib-i3b2w-qa54f-6vcz4-phxfq-x7tqy-fmysp-d7ziz-iupdr-how76-4ae";
            seerBalance = 3000;
            expSeerBalance = 3000; 
            markets = []; 
            handle = "prateek";
        };

        let u6: UserResult = {
            id = "iybfb-xvn6a-4gxtd-mdrwn-yxnm6-lfs2o-ubgnt-woywg-hmq5i-aq6ez-sae";
            seerBalance = 1000;
            expSeerBalance = 1000;
            markets = []; 
            handle = "yogi";
        };

        let u7: UserResult = {
            id = "m6bw4-onqx2-zoks7-k6r47-3ip2e-kmcdx-pm5a4-pw2ox-jiz3y-xhhgr-6ae";
            seerBalance = 3000;
            expSeerBalance = 3000;
            markets = [];
            handle = "crypto";
        };

        let u8: UserResult = {
            id = "3srra-6v6ls-4u6ov-evz5e-gnhdk-pfgh5-jvl5b-o2y5g-42bll-xcmxd-sae";
            seerBalance = 1000;
            expSeerBalance = 1000;
            markets = []; 
            handle = "Satoshi";
        };

        let u9: UserResult = {
            id = "53r7a-ne5x5-ajjit-getbg-begdq-sm4qf-rixg7-ecpud-zg6ls-feurl-sqe";
            seerBalance = 3000;
            expSeerBalance = 3000;
            markets = []; 
            handle = "Ben";
        };

        let u10: UserResult = {
            id = "yfzu6-2bg44-iokgo-ya6gj-liri2-hpdm5-urdx3-rd2s3-5vfoj-pdwwb-fae";
            seerBalance = 3000; 
            expSeerBalance = 3000;
            markets = []; 
            handle = "dent";   
        };

        let u11: UserResult = {
            id = "65kbu-nfzqf-hsgbn-2ghvq-5eqeo-mxzvl-wwl3g-pwlpr-o27ea-anbro-dqe";
            seerBalance = 1000; 
            expSeerBalance = 1000;
            markets = [];
            handle = "5irechain";
        }; 

        let u12: UserResult = { 
            id = "ohn3m-eyegu-wmvwf-dalya-ga7yx-vmjt4-cgbx7-oaxmi-soofj-ntz4s-qae";
            seerBalance = 3000; 
            expSeerBalance = 3000;
            markets = []; 
            handle = "EarlyBird";
        }; 
    

        let u13: UserResult = { 
            id = "sf6py-i56md-qx7hb-wr3gv-xm7en-aqhqb-syaym-tsxvk-6clzr-ghpgk-pqe"; 
            seerBalance = 3000;
            expSeerBalance = 3000;
            markets = [];
            handle = "fiatcoin";
        }; 

        let u14: UserResult = { 
            id = "b6rg2-hekdq-kq3cc-kczmd-hstmr-pptzh-pbvif-4riaz-kdl26-hiyuu-gqe";
            seerBalance = 3000;
            expSeerBalance = 3000;
            markets = [];
            handle = "Sal_Paradise";
        }; 
    

        let u15: UserResult = {
            id = "p5ijg-6qr7e-nhy3n-rddbt-k4spj-gniyd-fznyc-z67sk-36qwq-2sfgy-aae";
            seerBalance = 3000;
            expSeerBalance = 3000;
            markets = [];
            handle = "Dev0";
        }; 
    
        let b: [Balance] = [0, 3937.5, 0];
        let um: UserMarket = {
            shares = 0;
            marketId = 18;
            balances = b;
            marketTitle = "ICP Price - End of April";
        };
        let u16: UserResult = {
            id = "zmrbi-3z3m2-dc55a-nrwmo-hy6gy-ksxns-wfhex-yac3r-ojjw2-kr2uo-sae";
            seerBalance = 0;
            expSeerBalance = 0;
            markets = [um];
            handle = "@emmanuel6milli";
        }; 

        let u17: UserResult = {
            id = "s6scp-ye57s-7z54d-6ijdm-xyv4h-eye6f-luqa6-rjz24-3humv-molty-yae";
            seerBalance = 3000;
            expSeerBalance = 3000;
            markets = [];
            handle = "Rothschild.icp";
        }; 
    
 
        let u18: UserResult = { 
            id = "7aw4k-wruvn-ywdgz-cvy6p-lcavb-o2vqz-y73bt-va3j2-nj4vs-5lw2p-cae";
            seerBalance = 3000;
            expSeerBalance = 3000;
            markets = [];
            handle = "Lamriver";    
        }; 

        let u19: UserResult = {
            id = "jurv6-zfnnt-v66uc-qjutu-axhnm-4hwog-ug3ci-mzoyr-qjria-otbtt-wqe";
            seerBalance = 1000;
            expSeerBalance = 1000;
            markets = [];
            handle = "nftview";
        }; 

        let u20: UserResult = {
            id = "picru-kebxg-2kws3-rwrzn-uj3a4-w2fch-nnesj-zfh3f-m3fm4-iehk4-wqe";
            seerBalance = 1000;
            expSeerBalance = 1000;
            markets = [];
            handle = "unstop";
        }; 
    
        let u21: UserResult = {
            id = "2djls-afiaz-obvxu-khu45-allty-czp2c-6zlyz-dgphh-vchho-6hp3a-iae";
            seerBalance = 3000;
            expSeerBalance = 3000;
            markets = [];
            handle = "crowfound";
        }; 

        let um2: UserMarket = {
            shares = 0;
            marketId = 14;
            balances: [Balance] = [1055.5555555555557, 0, 0];
            marketTitle = "Champions League: Benfica vs Liverpool";
        };

        let u22: UserResult = {
            id = "q72gt-z7tep-4ud2j-myxw4-kaaun-do2el-bdniy-ecrbp-4iww7-jplbe-rae";
            seerBalance = 2500;
            expSeerBalance = 2500;
            markets = [um2];
            handle = "ShadowySuperCoder";
        }; 
    
        let u23: UserResult = {
            id = "w6gib-7lkv2-rdndx-z6dfu-nsxvp-xfcr5-jsi7v-5yysk-bsu4y-4kynh-6qe";
            seerBalance = 1000;
            expSeerBalance = 1000;
            markets = [];
            handle = "cipoto";
        }; 
    
        let u24: UserResult = {
            id = "omm3v-nhtgc-76xri-kaa23-4hu32-3ucit-pntkv-gspql-r4b4a-qnxvo-uae"; 
            seerBalance = 3000;
            expSeerBalance = 3000;
            markets = [];
            handle = "1957999";
        }; 
    
        let u25: UserResult = {
            id = "7f6zt-35giu-byd4s-fc7yq-taavl-w5lvp-mvemt-km7tj-ee5vq-4x4zj-vqe";
            seerBalance = 3000;
            expSeerBalance = 3000;
            markets = [];
            handle = "MLAF";
        }; 
    
        let u26: UserResult = {
            id = "dqebi-uzw4a-nbsdn-6ap5p-gdfxr-527ij-uc2dt-cvytr-6mlun-iw534-qae";
            seerBalance = 1000;
            expSeerBalance = 1000;
            markets = [];
            handle = "turtlesea";
        }; 

        let u27: UserResult = {
            id = "sypmr-e6iqm-g3d5a-a3nn3-aswme-3a5vq-2un3k-jbpg6-5c2pc-ho2gn-jae";
            seerBalance = 1000;
            expSeerBalance = 1000;
            markets = [];
            handle = "minhanh";
        };


        let u28: UserResult = {
            id = "5ynee-3ch7c-5oofm-vhx3y-r4kae-rs3ao-uodm2-5psdj-k7dw5-ft6zw-iae";
            seerBalance = 3000;
            expSeerBalance = 3000;
            markets = [];
            handle = "Prime";
        }; 
    
        let u29: UserResult = {
            id = "azrha-kjlrz-hrv7e-l2nrw-pzfzg-lgyz5-wwj2g-fxykg-q5kva-w7cjj-sae";
            seerBalance = 3000;
            expSeerBalance = 3000;
            markets = [];
            handle = "Galactic";
        }; 
    
        let u30: UserResult = {
            id = "mfypp-abbts-vnlqc-uwocf-ejaxm-3ikew-y35r2-mn7c3-ha74k-53rhh-4ae";
            seerBalance = 1000;
            expSeerBalance = 1000;
            markets = [];
            handle = "Dice";
        };
    
        let userBack: [(UserId, UserResult)] = [
            (u0.id, u0),
            (u1.id, u1),
            (u2.id, u2),
            (u3.id, u3),
            (u4.id, u4),
            (u5.id, u5),
            (u6.id, u6),
            (u7.id, u7),
            (u8.id, u8),
            (u9.id, u9),
            (u10.id, u10),
            (u11.id, u11),
            (u12.id, u12),
            (u13.id, u13),
            (u14.id, u14),
            (u15.id, u15),
            (u16.id, u16),
            (u17.id, u17),
            (u18.id, u18),
            (u19.id, u19),
            (u20.id, u20),
            (u21.id, u21),
            (u22.id, u22),
            (u23.id, u23),
            (u24.id, u24),
            (u25.id, u25),
            (u26.id, u26),
            (u27.id, u27),
            (u28.id, u28),
            (u29.id, u29),
            (u30.id, u30),
        ];

        let usersIter = Iter.map<(UserId, UserResult), (UserId, User)>(
            // stableUsers.vals(), 
            userBack.vals(),
            func (e: (UserId, UserResult)): (UserId, User) {
                return (e.0, userResultToUser(e.1));
            }
        );
        
        Map.fromIter<UserId, User>(
            usersIter,
            10, 
            Text.equal, 
            Text.hash
        )
    };
    
    private var marketMap = do {
        let m0: (MarketId, MarketResult) = (14, {
            k = 1000000000;
            id = 14;
            title = "Champions League: Benfica vs Liverpool";
            probabilities = [
                627.9069767441861,
                186.046511627907,
                186.046511627907,
            ];
            endDate = 1_649_624_400_000_000_000;
            labels = ["Benfica", "Liverpool", "Draw" ];
            liquidity = 1500;
            reserves = [
                444.44444444444446,
                1500,
                1500,
            ];
            description = "SL Benfica is going head to head with Liverpool starting on 5 Apr 2022 at 19:00 UTC at Estadio do Sport Lisboa e Benfica stadium, Lisbon city, Portugal. The match is a part of the UEFA Champions League.";
            volume = 500;
            author = "q72gt-z7tep-4ud2j-myxw4-kaaun-do2el-bdniy-ecrbp-4iww7-jplbe-rae";
            state = #open;
            imageUrl = "https://upload.wikimedia.org/wikipedia/nap/thumb/f/f3/Logo_UEFA_Champions_League.png/250px-Logo_UEFA_Champions_League.png";
            providers = [
                "q72gt-z7tep-4ud2j-myxw4-kaaun-do2el-bdniy-ecrbp-4iww7-jplbe-rae",
            ];
            comments = [
                {
                    content = "No rational bet, I just love Lisbon and Benfica :)";
                    author = "ShadowySuperCoder";
                }
            ];
            totalShares = 0;
            blockTimestampLast = 1_648_829_451_234_346_240;
            startDate = 1_648_829_451_234_346_240;
            images = [];
        });

        let m1: (MarketId, MarketResult) = (15, {
            k = 1000000000;
            id = 15;
            title = "Champions League: Villarreal vs Bayern M.";
            probabilities = [
                333.3333333333333,
                333.3333333333333,
                333.3333333333333,
            ];
            endDate = 1_649_624_400_000_000_000;
            labels = ["Villarreal", "Bayern", "Draw"];
            liquidity = 1000;
            reserves = [1000, 1000, 1000];
            description = "Villarreal is going head to head with Bayern München starting on 6 Apr 2022 at 19:00 UTC at Estadio de la Ceramica stadium, Villarreal city, Spain. The match is a part of the UEFA Champions League.";
            volume = 0;
            author = "q72gt-z7tep-4ud2j-myxw4-kaaun-do2el-bdniy-ecrbp-4iww7-jplbe-rae";
            state = #open;
            imageUrl = "https://upload.wikimedia.org/wikipedia/nap/thumb/f/f3/Logo_UEFA_Champions_League.png/250px-Logo_UEFA_Champions_League.png";
            providers = [
                "q72gt-z7tep-4ud2j-myxw4-kaaun-do2el-bdniy-ecrbp-4iww7-jplbe-rae",
            ];
            comments = [];
            totalShares = 0;
            blockTimestampLast = 1_648_829_658_797_510_840;
            startDate = 1_648_829_658_797_510_840;
            images = [];
        });

        
        let m2: (MarketId, MarketResult) = (16, {
            k = 1000000000;
            id = 16;
            title = "Champions League: M. City vs Atl. Madrid";
            probabilities = [
                333.3333333333333,
                333.3333333333333,
                333.3333333333333,
            ];
            endDate = 1_649_624_400_000_000_000;
            labels = ["M. City", "Atl. Madrid", "Draw" ];
            liquidity = 1000;
            reserves = [1000, 1000, 1000];
            description = "Manchester City is going head to head with Atlético Madrid starting on 5 Apr 2022 at 19:00 UTC at Etihad Stadium stadium, Manchester city, England. The match is a part of the UEFA Champions League.";
            volume = 0;
            author = "q72gt-z7tep-4ud2j-myxw4-kaaun-do2el-bdniy-ecrbp-4iww7-jplbe-rae";
            state = #open;
            imageUrl = "https://upload.wikimedia.org/wikipedia/nap/thumb/f/f3/Logo_UEFA_Champions_League.png/250px-Logo_UEFA_Champions_League.png";
            providers = [
                "q72gt-z7tep-4ud2j-myxw4-kaaun-do2el-bdniy-ecrbp-4iww7-jplbe-rae"
            ];
            comments = [];
            totalShares = 0;
            blockTimestampLast = 1_648_829_862_423_293_816;
            startDate = 1_648_829_862_423_293_816;
            images = [];
        });



        let m3: (MarketId, MarketResult) = (17, {
            k = 1000000000;
            id = 17;
            title = "Champions League: Chelsea vs Real Madrid";
            probabilities = [
                333.3333333333333,
                333.3333333333333,
                333.3333333333333,
            ];
            endDate = 1_649_624_400_000_000_000;
            labels = ["Chelsea", "Real Madrid", "Draw"];
            liquidity = 1000;
            reserves = [1000, 1000, 1000];
            description = "Chelsea is going head to head with Real Madrid starting on 6 Apr 2022 at 19:00 UTC at Stamford Bridge stadium, London city, England. The match is a part of the UEFA Champions League.";
            volume = 0;
            author = "q72gt-z7tep-4ud2j-myxw4-kaaun-do2el-bdniy-ecrbp-4iww7-jplbe-rae";
            state = #open;
            imageUrl = "https://upload.wikimedia.org/wikipedia/nap/thumb/f/f3/Logo_UEFA_Champions_League.png/250px-Logo_UEFA_Champions_League.png";
            providers = [
                "q72gt-z7tep-4ud2j-myxw4-kaaun-do2el-bdniy-ecrbp-4iww7-jplbe-rae"
            ];
            comments = [];
            totalShares = 0;
            blockTimestampLast = 1_648_829_978_192_965_591;
            startDate = 1_648_829_978_192_965_591;
            images = [];
        });



        let m4: (MarketId, MarketResult) = (18, {
            k = 1000000000;
            id = 18;
            title = "ICP Price - End of April";
            probabilities = [
                15.151515151515152,
                969.6969696969697,
                15.151515151515152,
            ];
            endDate = 1_651_525_200_000_000_000;
            labels = ["Less 20", "20 to 40", "More 40"];
            liquidity = 4000;
            reserves = [4000, 62.5, 4000];
            description = "What would be the price of ICP by the end of April?";
            volume = 3000;
            author = "q72gt-z7tep-4ud2j-myxw4-kaaun-do2el-bdniy-ecrbp-4iww7-jplbe-rae";
            state = #open;
            imageUrl = "https://cryptomode.com/wp-content/uploads/2021/08/CryptoMode-DFINITY-Internet-Computer-ICP.jpg";
            providers = [
                "q72gt-z7tep-4ud2j-myxw4-kaaun-do2el-bdniy-ecrbp-4iww7-jplbe-rae"
            ];
            comments = [];
            totalShares = 0;
            blockTimestampLast = 1_648_830_325_723_878_200;
            startDate = 1_648_830_325_723_878_200;
            images = [];
        });



        let m5: (MarketId, MarketResult) = (19, {
            k = 1000000000;
            id = 19;
            title = "Bitcoin Price - End of April";
            probabilities = [
                463.519313304721,
                268.24034334763945,
                268.24034334763945,
            ];
            endDate = 1_651_525_200_000_000_000;
            labels = ["Less 40k", "40k to 50k", "More 50k"];
            liquidity = 1200;
            reserves = [
                694.4444444444445,
                1200,
                1200,
            ];
            description = "What will be the price of Bitcoin BTC by the end of April?";
            volume = 200;
            author = "q72gt-z7tep-4ud2j-myxw4-kaaun-do2el-bdniy-ecrbp-4iww7-jplbe-rae";
            state = #open;
            imageUrl = "https://www.dhresource.com/0x0/f2/albu/g9/M00/27/85/rBVaVVxO822ACwv4AALYau1h4a8355.jpg/500pcs-30mm-diameter-bitcoin-logo-label-sticker.jpg";
            providers = [
                "q72gt-z7tep-4ud2j-myxw4-kaaun-do2el-bdniy-ecrbp-4iww7-jplbe-rae"
            ];
            comments = [];
            totalShares = 0;
            blockTimestampLast = 1_648_830_489_828_973_969;
            startDate = 1_648_830_489_828_973_969;
            images = [];
        });




        let m6: (MarketId, MarketResult) = (20, {
            k = 1000000;
            id = 20;
            title = "Donald Trump could win the White House again in 2024";
            probabilities = [500, 500];
            endDate = 1_737_410_400_000_000_000;
            labels = ["Yes", "No"];
            liquidity = 1000;
            reserves = [1000, 1000];
            description = "It\'s January 20, 2025. Donald Trump places his hand on a Bible. He\'s president of the United States. Again.";
            volume = 0;
            author = "q72gt-z7tep-4ud2j-myxw4-kaaun-do2el-bdniy-ecrbp-4iww7-jplbe-rae";
            state = #open;
            imageUrl = "https://i.ibb.co/BwqLg14/trump-7080.jpg";
            providers = [
                "q72gt-z7tep-4ud2j-myxw4-kaaun-do2el-bdniy-ecrbp-4iww7-jplbe-rae"
            ];
            comments = [
                {
                    content = "Thanks Seersmarket! Very cool! ";
                    author = "@emmanuel6milli";
                }
            ];
            totalShares = 0;
            blockTimestampLast = 1_648_831_059_983_825_606;
            startDate = 1_648_831_059_983_825_606;
            images = [];
        });


            
        let m7: (MarketId, MarketResult) = (21, {
            k = 1000000;
            id = 21;
            title = "Will Queen Elizabeth live to age 96?";
            probabilities = [900, 99.99999999999999];
            endDate = 1_650_574_800_000_000_000;
            labels = ["Yes", "No"];
            liquidity = 3000;
            reserves = [333.3333333333333, 3000];
            description = "Will the Queen of the United Kingdom and 14 Commonwealths live past her 96th birthday? You decide. The date is coming fast (April 21), so submit your bets with haste!";
            volume = 2000;
            author = "q72gt-z7tep-4ud2j-myxw4-kaaun-do2el-bdniy-ecrbp-4iww7-jplbe-rae";
            state = #open;
            imageUrl = "https://i0.web.de/image/278/36722278,pd=1,f=responsive169-w950/queen-elizabeth-ii.jpg";
            providers = [
                "q72gt-z7tep-4ud2j-myxw4-kaaun-do2el-bdniy-ecrbp-4iww7-jplbe-rae"
            ];
            comments = [
                {
                    content = "It\'s only 20 days, what could go wrong?";
                    author = "Satoshi";
                },
                { content = "I hope so, got a big Yes bag."; author = "Dev0" }
            ];
            totalShares = 0;
            blockTimestampLast = 1_648_831_319_092_948_610;
            startDate = 1_648_831_319_092_948_610;
            images = [];
        });

        let marketBack: [(MarketId, MarketResult)] = [
            m0, m1, m2, m3, m4, m5, m6, m7
        ];


        let marketIter = Iter.map<(MarketId, MarketResult), (MarketId, Market)>(
            marketBack.vals(),
            // stableMarkets.vals(), 
            func (e: (MarketId, MarketResult)): (MarketId, Market) {
                return (e.0, marketResultToMarket(e.1));
            }
        );
        
        Map.fromIter<MarketId, Market>(
            marketIter,
            10, 
            Nat32.equal, 
            func (x: Nat32): Nat32 { x } 
        )
    };

    /* Update */
    system func preupgrade() {
        // stableUsers := Trie.toArray<UserId, User, (UserId, UserResult)>(
        //     users,
        //     func (id: UserId, u: User): (UserId, UserResult) {
        //         return (id, userToUserResult(u));
        //     }
        // );
        // stableMarkets := Trie.toArray<MarketId, Market, (MarketId, MarketResult)>(
        //     markets,
        //     func (id: MarketId, m: Market): (MarketId, MarketResult) {
        //         return (id, marketToMarketResult(m));
        //     }
        // );
    };

    system func postupgrade() {
        Debug.print("upgraded");
    };

    /* API */

    // Tip all users.
    // public shared(msg) func tipAllUsers(): async () {
    //     assert(msg.caller == initializer); // Root call.

    //     users := Trie.mapFilter(users, func (id: UserId, user: User): ?User {
    //         if (user.markets.size() > 0) {
    //             user.seerBalance := user.seerBalance + 3000 - user.seerBalance;
    //         };
    //         return ?user;
    //     });
    // };

    // Read all users.
    public query func readAllUsers(): async [(UserId, UserResult)] {
        return [];
        // return Iter.toArray(userMap.entries());
        // let result = Trie.toArray(users, func (id: UserId, u: User): UserResult {
        //     return userToUserResult(u);
        // });
        // return result;
    };

    // Delete all users.
    // public shared(msg) func deleteAllUsers(): async () {
    //     assert(msg.caller == initializer); // Root call.
       
    //     users := Trie.empty();
    // };

    // Approve a market.
    public shared(msg) func approveMarket(marketId: MarketId): async () {
        assert(msg.caller == initializer); // Root call.

        switch (marketMap.get(marketId)) {
            case (null) {
                return;
            };
            case (?market) {
                market.state := #open;
            };
        };
    }; 

    public shared(msg) func claimTokens(marketId: MarketId): async Balance {
        assert(not Principal.isAnonymous(msg.caller));

        let userId = Principal.toText(msg.caller);        
        let userOpt = userMap.get(userId);
        let marketOpt = marketMap.get(marketId);

        switch (marketOpt) {
            case (null) {
                return 0;
            };
            case (?market) {
                switch (market.state) {
                    case (#resolved(i)) {
                        switch (userOpt) {
                            case (null) {
                                return 0;
                            };
                            case (?user) {
                                var reward: Balance = 0;
                                user.markets := Array.mapFilter(user.markets, 
                                    func (ut: UserMarket): ?UserMarket {
                                        if (ut.marketId != market.id) {
                                            return ?ut;
                                        } else {
                                            reward := ut.balances[i];
                                            user.seerBalance := user.seerBalance + reward;
                                    
                                            return null;
                                        };
                                    }
                                );
                                return reward;
                            };
                        };
                    };
                    case (_) {
                        return 0;
                    };
                };
            };
        };
    };

    // public shared(msg) func resolveMarket(marketId: MarketId, option: Nat): async Bool {
    //     assert(msg.caller == initializer); // Root call.
    //     let marketOpt = Trie.find(markets, marketKey(marketId), Nat32.equal);
    //     switch (marketOpt) {
    //         case (null) {
    //             return false;
    //         };
    //         case (?market) {
    //             market.state := #resolved(option);
    //             return true;
    //         };
    //     };

    //     return false;
    // };

    public type CreateMarketError = {
        #callerIsAnon;
        #userNotCreated;
        #notEnoughLiquidity: Balance;
        #titleMissing;
        #descriptionMissing;
        #optionsMissing;
        #imageMissing;
        #endDateOld: Time.Time;
    };

    private func checkMarketInitData(marketInitData: MarketInitData): Result.Result<(), CreateMarketError> {
        if (marketInitData.liquidity < 100) {
            return #err(#notEnoughLiquidity(100));
        };

        if (marketInitData.title == "") {
            return #err(#titleMissing);
        };

        if (marketInitData.description == "") {
            return #err(#descriptionMissing);
        };

        if (marketInitData.labels.size() == 0) {
            return #err(#optionsMissing);
        };

        if (marketInitData.imageUrl == "") {
            return #err(#imageMissing);
        };

        if (marketInitData.endDate < Time.now()) {
            return #err(#endDateOld(marketInitData.endDate));
        };

        return #ok(());
    };

    // Create a new AMM market.
    public shared(msg) func createMarket(marketInitData: MarketInitData): async Result.Result<MarketResult, CreateMarketError> {
        if (Principal.isAnonymous(msg.caller)) {
            return #err(#callerIsAnon);
        };

        switch (checkMarketInitData(marketInitData)) {
            case (#err(e)) {
                return #err(e);
            };
            case (#ok(_)) { /* all good; continue */};
        };

        let author = Principal.toText(msg.caller);        
        let optionsLength = marketInitData.labels.size();
        let marketId = nextMarketId;
        let liquidity = marketInitData.liquidity;

        var reserves: [var Balance] = Array.init<Balance>(optionsLength, 0);
        let probabilities: [var Probability] = Array.init<Probability>(optionsLength, 1000 / Float.fromInt(optionsLength));
        
        var k: Balance = 1;

        for (i in Iter.range(0, optionsLength - 1)) {
            reserves[i] := liquidity;
            k := k * reserves[i];
        };
    
        // Dummy value.
        let shares = Float.toInt(Float.sqrt(0));

        let newMarket: Market = {
            id = marketId;
            title = marketInitData.title;
            description = marketInitData.description;
            startDate = Time.now();
            endDate = marketInitData.endDate;
            author = author;
            labels = marketInitData.labels;
            images = marketInitData.images;
            var probabilities = Array.freeze(probabilities);
            var liquidity = liquidity;
            var k = k;
            var reserves = Array.freeze(reserves);
            var blockTimestampLast = Time.now();
            var totalShares = shares;
            var providers = [author];
            var imageUrl = marketInitData.imageUrl;
            var state = #pending;
            var volume = 0;
            var comments = [];
        };

        // Update provider.
        var user = switch (getUser(author)) {
            case (null) {
                return #err(#userNotCreated);
            };
            case (?user) {
                user;
            };
        };
        
        let userMarket: UserMarket = {
            marketId = marketId;
            marketTitle = marketInitData.title;
            balances = Array.freeze(Array.init<Balance>(optionsLength, 0));
            shares = shares;
        };

        user.markets := Array.append(user.markets, [userMarket]);
        userMap.put(user.id, user);
        // users := Trie.replace(
        //     users,
        //     userKey(user.id),
        //     Text.equal,
        //     ?user,
        // ).0;

        nextMarketId += 1;

        marketMap.put(marketId, newMarket);

        // markets := Trie.replace(
        //     markets,
        //     marketKey(marketId),
        //     Nat32.equal,
        //     ?newMarket,
        // ).0;

        return #ok(marketToMarketResult(newMarket));
    };

    // Read a market.
    public query func readMarket(marketId: MarketId): async ?MarketResult {
        let result = marketMap.get(marketId);
        return Option.map(result, marketToMarketResult);        
    };

    // Read all markets.
    public query func readAllMarkets(): async [(MarketId, MarketResult)] {
        // let result = Trie.toArray(markets, getMarket);
        // return Array.map(result, marketToMarketResult);
        // Iter.toArray(marketMap.entries())
        return [];
    };

    // Read all open markets.
    public query func readAllOpenMarkets(): async [MarketResult] {
        // let array = Iter.toArray(marketMap.entries());
        // return Array.mapFilter(array, keepOpenMarkets);
        return [];
    };

    private type RefreshUserError = {
        #callerIsAnon;
        #userNotCreated;
    };

    public shared(msg) func refreshUser(): async Result.Result<UserResult, RefreshUserError> {
        if (Principal.isAnonymous(msg.caller)) {
            return #err(#callerIsAnon);
        };

        let caller = Principal.toText(msg.caller);
        let userOpt = userMap.get(caller);

        switch (userOpt) {
            case (null) {
                return #err(#userNotCreated);
            };
            case (?user) {
                user.expSeerBalance := user.seerBalance;
                user.markets := Array.mapFilter(user.markets, 
                    func (ut: UserMarket): ?UserMarket {
                        
                        let marketOpt = marketMap.get(ut.marketId);
                        
                        switch (marketOpt) {
                            case (null) {
                                // Market was deleted so we delete its data from the user.
                                return null;
                            };
                            case (?market) {
                                switch (market.state) {
                                    case (#resolved(i)) {
                                        let reward = ut.balances[i];
                                        // Give reward to user and delete market.
                                        user.seerBalance := user.seerBalance + reward;
                                        return null;
                                    };
                                    case _ {
                                        // Market still open. Update expected balance.
                                        let optionsSize = market.probabilities.size();

                                        for (j in Iter.range(0, optionsSize - 1)) {
                                            user.expSeerBalance := user.expSeerBalance 
                                                + market.probabilities[j] * ut.balances[j] / 1000.0; 
                                        };

                                        return ?ut;
                                    };
                                };
                            };
                        };
                    }
                );
                return #ok(userToUserResult(user));
            };
        };
    };

    // Delete a market.
    // public shared(msg) func deleteMarket(marketId: MarketId): async Bool {
    //     assert(msg.caller == initializer); // Root call.
        
    //     let result = Trie.find(markets, marketKey(marketId), Nat32.equal);
    //     let exists = Option.isSome(result);
    //     if (exists) {
    //         markets := Trie.replace(
    //             markets,
    //             marketKey(marketId),
    //             Nat32.equal,
    //             null,
    //         ).0;
    //     };
    //     return exists;
    // };

    // Delete all market.
    // public shared(msg) func deleteAllMarkets(): async () {
    //     assert(msg.caller == initializer); // Root call.
        
    //     nextMarketId := 0;
    //     markets := Trie.empty();
    // };


    public type TradeError = {
        #callerIsAnon;
        #userNotCreated;
        #notEnoughBalance;
        #marketMissing;
        #marketClosed;
        #newtonFailed;
    };

    // Sell tokens from caller back to the market.
    // public shared(msg) func sellOption(
    //     marketId: MarketId,
    //     value: Balance,
    //     selected: Nat,
    //     save: Bool
    // ): async Result.Result<Balance, TradeError> {

    //     if (Principal.isAnonymous(msg.caller)) {
    //         return #err(#callerIsAnon);
    //     };

    //     let caller = Principal.toText(msg.caller);
    //     let marketOpt = Trie.find(markets, marketKey(marketId), Nat32.equal);
        
    //     switch (marketOpt) {
    //         case null {
    //             return #err(#marketMissing);
    //         };
    //         case (?market) {
    //             if (market.endDate < Time.now()) {
    //                 market.state := #closed;
    //                 return #err(#marketClosed);
    //             };

    //             var user = switch (getUser(caller)) {
    //                 case (null) {
    //                     return #err(#userNotCreated);
    //                 };
    //                 case (?user) {
    //                     user;
    //                 };
    //             };
        
    //             var marketTokensOpt = Array.find(user.markets,
    //                 func (ut: UserMarket): Bool {
    //                     ut.marketId == market.id
    //                 }
    //             );

    //             switch (marketTokensOpt) {
    //                 case null {
    //                     // No tokens to sell.
    //                     return #err(#notEnoughBalance);
    //                 };
    //                 case (?marketTokens) {
    //                     if (marketTokens.balances[selected] < value) {
    //                         // No enought tokens to sell.
    //                         return #err(#notEnoughBalance);
    //                     };

    //                     let optionsSize = market.reserves.size();
    //                     var newReserves: [var Balance] = Array.init(optionsSize, 0.0);
                        
    //                     for (i in Iter.range(0, optionsSize - 1)) {
    //                         newReserves[i] := market.reserves[i];
    //                     };
    //                     newReserves[selected] := newReserves[selected] + value;

    //                     let f = func (x: Float): Float {
    //                         var calcK: Float = 1;
    //                         for (i in Iter.range(0, optionsSize - 1)) {
    //                             calcK := calcK * (newReserves[i] - x);
    //                         };

    //                         return calcK - market.k;               
    //                     };

    //                     var rOpt = newtonMethod(0.0, f);

    //                     switch (rOpt) {
    //                         case (null) {
    //                             return #err(#newtonFailed);
    //                         };
    //                         case (?r) {
    //                             for (i in Iter.range(0, optionsSize - 1)) {
    //                                 newReserves[i] := newReserves[i] - r;
    //                             };
    //                             let newLiquidity = market.liquidity - r;
    //                             let liquidityOut: Balance = r;

    //                             if (not save) {
    //                                 return #ok(liquidityOut);
    //                             };
                                
    //                             market.volume := market.volume + liquidityOut;
    //                             market.reserves := Array.freeze(newReserves);

    //                             let weight: [var Balance] = Array.init(optionsSize, 1.0); 
    //                             let probabilities: [var Probability] = Array.init(optionsSize, 0.0);
    //                             var weightSum: Balance  = 0.0;
                                    
    //                             for (i in Iter.range(0, optionsSize - 1)) {
    //                                 for (j in Iter.range(0, optionsSize - 1)) {
    //                                     if (i != j) {
    //                                         weight[i] := weight[i] * market.reserves[j];
    //                                     };
    //                                 };
    //                                 weightSum := weightSum + weight[i];
    //                             };

    //                             for (i in Iter.range(0, optionsSize - 1)) {
    //                                 probabilities[i] := weight[i] * 1000.0 / weightSum;
    //                             };

    //                             market.probabilities := Array.freeze(probabilities);

    //                             user.markets := Array.mapFilter(user.markets, 
    //                                 func (ut: UserMarket): ?UserMarket {
    //                                     if (ut.marketId != market.id) {
    //                                         return ?ut;
    //                                     } else {
    //                                         let newBalances = Array.mapEntries(ut.balances,
    //                                             func (b: Balance, i: Nat): Balance {
    //                                                 if (i == selected) {
    //                                                     return b - value;
    //                                                 } else {
    //                                                     return b;
    //                                                 };
    //                                             }
    //                                         );

    //                                         let newUserMarket: UserMarket = {
    //                                             marketId = market.id;
    //                                             marketTitle = market.title;
    //                                             balances = newBalances;
    //                                             shares = ut.shares;
    //                                         };

    //                                         return ?newUserMarket;
    //                                     };
    //                                 }
    //                             );

    //                             user.seerBalance := user.seerBalance + liquidityOut;

    //                             return #ok(liquidityOut);
    //                         };
    //                     };
    //                 };
    //             };
    //         };
    //     };
    // };

    // public shared(msg) func buyOption(
    //         marketId: MarketId,
    //         value: Balance,
    //         selected: Nat,
    //         save: Bool
    //     ): async Result.Result<Balance, TradeError> {

    //     if (Principal.isAnonymous(msg.caller)) {
    //         return #err(#callerIsAnon);
    //     };

    //     let caller = Principal.toText(msg.caller);
        
    //     var user = switch (getUser(caller)) {
    //         case (null) {
    //             return #err(#userNotCreated);
    //         };
    //         case (?user) {
    //             user;
    //         };
    //     };

    //     if (user.seerBalance < value) {
    //         return #err(#notEnoughBalance);
    //     };
        
    //     let marketOpt = Trie.find(markets, marketKey(marketId), Nat32.equal);

    //     switch (marketOpt) {
    //         case null {
    //             return #err(#marketMissing);
    //         };
    //         case (?market) {
    //             if (market.endDate < Time.now()) {
    //                 market.state := #closed;
    //                 return #err(#marketClosed);
    //             };
                
    //             let optionsSize = market.reserves.size();
    //             var semiK: Balance = 1.0;

    //             for (i in Iter.range(0, optionsSize - 1)) {
    //                 if (i != selected) {
    //                     semiK := semiK * (market.reserves[i] + value);
    //                 };
    //             };
                
    //             let newSelectedReserve: Balance = market.k / semiK;
    //             let tokensOut = market.reserves[selected] - newSelectedReserve + value;
                
    //             if (not save) { // Dry run.
    //                 return #ok(tokensOut);
    //             };

    //             var newReserves: [var Balance] = Array.init(optionsSize, 0.0);
    //             let newLiquidity = market.liquidity + value;
               
    //             for (i in Iter.range(0, optionsSize - 1)) {
    //                 if (i != selected) {
    //                     newReserves[i] := market.reserves[i] + value;
    //                 } else {
    //                     newReserves[i] := newSelectedReserve;
    //                 };
    //             };
                
    //             market.reserves := Array.freeze(newReserves);
    //             market.liquidity := newLiquidity;
    //             market.volume := market.volume + value;

    //             let weight: [var Balance] = Array.init(optionsSize, 1.0); 
    //             let probabilities: [var Probability] = Array.init(optionsSize, 0.0);
    //             var weightSum: Balance  = 0.0;
                    
    //             for (i in Iter.range(0, optionsSize - 1)) {
    //                 for (j in Iter.range(0, optionsSize - 1)) {
    //                     if (i != j) {
    //                         weight[i] := weight[i] * market.reserves[j];
    //                     };
    //                 };
    //                 weightSum := weightSum + weight[i];
    //             };

    //             for (i in Iter.range(0, optionsSize - 1)) {
    //                 probabilities[i] := weight[i] * 1000.0 / weightSum;
    //             };

    //             market.probabilities :=  Array.freeze(probabilities);

    //             var marketTokensOpt = Array.find(user.markets,
    //                 func (ut: UserMarket): Bool {
    //                     ut.marketId == market.id
    //                 }
    //             );

    //             switch (marketTokensOpt) {
    //                 case null {
    //                     let balances: [var Balance] = Array.init(optionsSize, 0.0);
    //                     balances[selected] := tokensOut;

    //                     let newUserMarket: UserMarket = {
    //                         marketId = market.id;
    //                         marketTitle = market.title;
    //                         balances = Array.freeze(balances);
    //                         shares = 0;
    //                     };
    //                     user.markets := Array.append(user.markets, [newUserMarket]);
    //                 };
    //                 case (?marketTokens) {
    //                     user.markets := Array.mapFilter(user.markets, 
    //                         func (ut: UserMarket): ?UserMarket {
    //                             if (ut.marketId != market.id) {
    //                                 return ?ut;
    //                             } else {
    //                                 let newBalances = Array.mapEntries(ut.balances,
    //                                     func (b: Balance, i: Nat): Balance {
    //                                         if (i == selected) {
    //                                             return b + tokensOut;
    //                                         } else {
    //                                             return b;
    //                                         };
    //                                     }
    //                                 );

    //                                 let newUserMarket: UserMarket = {
    //                                     marketId = market.id;
    //                                     marketTitle = market.title;
    //                                     balances = newBalances;
    //                                     shares = ut.shares;
    //                                 };
    //                                 return ?newUserMarket;
    //                             };
    //                         }
    //                     );
    //                 };
    //             };

    //             user.seerBalance := user.seerBalance - value;

    //             return #ok(tokensOut);
    //         };
    //     };
    // };

    // Get user data.
    public query func getUserResult(userId: UserId): async ?UserResult {
        return Option.map(getUser(userId), userToUserResult);
    };

    // Create user.
    public shared(msg) func createUserResult(handle: Text): async Result.Result<UserResult, CreateUserError> {
        if (Principal.isAnonymous(msg.caller)) {
            return #err(#userIsAnon);
        };

        let caller = Principal.toText(msg.caller);

        switch (createUser(caller, handle)) {
            case (#err(e)) {
                return #err(e);
            };
            case (#ok(user)) {
                return #ok(userToUserResult(user))
            };
        };
    };

    // Tip a user
    // public shared(msg) func tip(id: UserId, value: Balance): async ?Balance {
    //     assert(msg.caller == initializer); // Root call.

    //     var user = switch (getUser(id)) {
    //         case (null) {
    //             return null;
    //         };
    //         case (?user) {
    //             user;
    //         };
    //     };
    //     user.seerBalance := user.seerBalance + value;

    //     return ?user.seerBalance;
    // };

    // Edit market image.
    // public shared(msg) func editMarketImage(marketId: MarketId, newImage: Text): async Bool {
    //     assert(msg.caller == initializer); // Root call.

    //     let marketOpt = Trie.find(markets, marketKey(marketId), Nat32.equal);

    //     switch (marketOpt) {
    //         case null {
    //             return false;
    //         };
    //         case (?market) {
    //             market.imageUrl := newImage;
    //             return true;
    //         };
    //     };

    //     return false;
    // };

    private type AddCommentError = {
        #userIsAnon;
        #userNotCreated;
        #marketMissing;
        #commentIsEmpty;
    };

    // Add a comment to a market.
    // public shared(msg) func addCommentToMarket(marketId: MarketId, content: Text): async Result.Result<Comment, AddCommentError> {
    //     if (Principal.isAnonymous(msg.caller)) {
    //         return #err(#userIsAnon);
    //     };

    //     if (content == "") {
    //         return #err(#commentIsEmpty);
    //     };

    //     let userId = Principal.toText(msg.caller);
    //     let userOpt = Trie.find(users, userKey(userId), Text.equal);

    //     switch (userOpt) {
    //         case null {
    //             return #err(#userNotCreated);
    //         };
    //         case (?user) {
    //             let marketOpt = Trie.find(markets, marketKey(marketId), Nat32.equal);

    //             switch (marketOpt) {
    //                 case null {
    //                     return #err(#marketMissing);
    //                 };
    //                 case (?market) {
    //                     let comment: Comment = {
    //                         author = user.handle;
    //                         content = content;
    //                     };
    //                     market.comments := Array.append(market.comments, [comment]);
                        
    //                     return #ok(comment);
    //                 };
    //             };
    //         };
    //     };
    // };

    /**
    * Utilities
    */

    private func userKey(x: UserId) : Trie.Key<UserId> {
        return { hash = Text.hash(x); key = x };
    };

    private func marketKey(x: MarketId) : Trie.Key<MarketId> {
        return { hash = x; key = x };
    };

    private func getMarket(k: MarketId, v: Market): Market {
        return v;
    };

    private func keepOpenMarkets(m: Market): ?MarketResult {
        switch (m.state) {
            case (#open) {
                let market = {
                    id = m.id;    
                    title = m.title;
                    description = m.description;
                    labels = m.labels;
                    images = m.images;
                    probabilities = m.probabilities;
                    liquidity = m.liquidity;
                    reserves = m.reserves;
                    k = m.k;
                    startDate = m.startDate;
                    endDate = m.endDate;
                    author = m.author;
                    blockTimestampLast = m.blockTimestampLast;
                    totalShares = m.totalShares;
                    providers = m.providers;
                    imageUrl = m.imageUrl;
                    state = m.state;
                    volume = m.volume;
                    comments = m.comments;
                };
                return ?market;
            };
            case _ {
                return null;
            };
        };
        return null;
    };

    private func getUser(userId: UserId): ?User {
        null
        // Trie.find(users, userKey(userId), Text.equal)
    };

    private type CreateUserError = {
        #userExist;
        #userIsAnon;
    };

    private func createUser(userId: UserId, handle: Text): Result.Result<User, CreateUserError> {
        let exist = Trie.find(handles, userKey(handle), Text.equal);

        switch (exist) {
            case (null) {
                let user: User = {
                    var id = userId;
                    var seerBalance = 1000.0; // Airdrop
                    var expSeerBalance = 1000.0;
                    var handle = handle;
                    var markets = [];
                };

                handles := Trie.replace(
                    handles,
                    userKey(handle),
                    Text.equal,
                    ?handle,
                ).0;

                userMap.put(userId, user);

                // users := Trie.replace(
                //     users,
                //     userKey(user.id),
                //     Text.equal,
                //     ?user,
                // ).0;

                return #ok(user);
            };
            case (userId) {
                return #err(#userExist);
            };
        };
    };

    private func newtonMethod(x0: Float, f: Float -> Float): ?Float {
        let tolerance = 1e-7;
        let epsylon = 2.220446049250313e-16;
        let h = 1e-4;
        let hr = 1/h;
        let maxIter = 100;
        
        var iter = 0;
        var prev = x0;
        
        while (iter < maxIter) {
            // Compute the value of the function.
            let y = f(prev);

            // Use numerica derivatives.
            let yph = f(prev + h);
            let ymh = f(prev - h);
            let yp2h = f(prev + 2 * h);
            let ym2h = f(prev - 2 * h);

            let yp = ((ym2h - yp2h) + 8 * (yph - ymh)) * hr / 12;

            if (Float.abs(yp) <= epsylon * Float.abs(y)) {
                return null;
            };

            // Update the guess.
            let next = prev - y / yp;

            // Check for convergence:
            if (Float.abs(next - prev) <= tolerance * Float.abs(next)) {
                return ?next;
            };

            prev := next;
            iter := iter + 1;
        };

        return null;
    };
};
