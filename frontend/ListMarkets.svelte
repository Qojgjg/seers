<script lang="ts">
  import { onMount } from "svelte"
  import Header from "./Header.svelte"

  const PAGE_SIZE = 20

  export let auth

  let markets = []

  const refreshMarkets = async () => {
    markets = await $auth.actor.readAllMarkets()
  }

  onMount(refreshMarkets)
</script>

<Header />

<h3>Prediction Markets</h3>

<div class="MarketList">
  {#each markets as market}
    <div class="responsive">
      <div class="gallery">
        <a href="#/market/{market.id}">
          <img src={market.imageUrl} alt="random" />
          <h5>{market.title}</h5>
        </a>
        <div>Yes: {market.yesProb}%</div>
        <div>No: {market.noProb}%</div>
        <div>Volume: $120,000</div>
        <div>Liquidity: $120,000,000</div>
      </div>
    </div>
  {/each}
</div>

<style global>
  .MarketList {
    width: 80%;
    margin: 0 5% 0 15%;
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
    padding: 0 6px;
    float: left;
    width: 24.99999%;
    margin: 1em;
  }

  @media only screen and (max-width: 700px) {
    .responsive {
      width: 49.99999%;
      margin: 6px 0;
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
