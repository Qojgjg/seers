<script lang="ts">
  import { onMount } from "svelte"

  const PAGE_SIZE = 20

  export let auth

  let markets = []

  const refreshMarkets = async () => {
    markets = await $auth.actor.readAllOpenMarkets()
  }

  onMount(refreshMarkets)
</script>

<div class="MarketList">
  <div style="width: 100%; display: flex; justify-content:center;">
    <h3>Prediction Markets</h3>
  </div>
  <div style="width: 100%; display: flex; justify-content:center; ">
    {#each markets as market}
      <div class="responsive">
        <a href="#/market/{market.id}">
          <div class="gallery">
            <img src={market.imageUrl} alt="random" />
            <h5>{market.title}</h5>
            <div>Yes: {market.yesProb}%</div>
            <div>No: {market.noProb}%</div>
            <div>Volume: {market.volume} S</div>
            <div>Liquidity: {market.liquidity} S</div>
          </div>
        </a>
      </div>
    {/each}
  </div>
</div>

<style global>
  .MarketList {
    width: 100%;
  }

  div.gallery {
    padding: 2em;
    background: rgb(220 218 224 / 10%);
    border-radius: 20px;
  }

  div.gallery:hover {
    padding: 2em;
    background: rgb(220 218 224 / 20%);
    border-radius: 20px;
  }

  div.gallery img {
    width: 100%;
    height: auto;
  }

  div.desc {
    padding: 15px;
    text-align: center;
  }

  * {
    box-sizing: border-box;
  }

  .responsive {
    float: left;
    width: 24.99999%;
    margin: 1em;
  }

  @media only screen and (max-width: 700px) {
    .responsive {
      width: 49.99999%;
      /* margin: 6px 0; */
    }
  }

  @media only screen and (max-width: 500px) {
    .responsive {
      width: 100%;
    }
  }

  .clearfix:after {
    content: "";
    display: table;
    clear: both;
  }
</style>
