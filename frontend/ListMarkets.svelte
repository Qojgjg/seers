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

<div class="header">
  <h3>Prediction Markets</h3>
</div>
<div class="rowList">
  {#each markets as market}
    <div class="responsiveItem">
      <a href="#/market/{market.id}">
        <div class="gallery">
          <img src={market.imageUrl} alt="random" />
          <h5>{market.title}</h5>
          <div style="margin-top: 10px; margin-bottom: 10px">
            {#each market.labels as label, i}
              <div>{label}: {Number(market.probabilities[i]) / 10.0}%</div>
            {/each}
          </div>
          <div>Volume: {market.volume} &Sigma;</div>
          <div>Liquidity: {market.liquidity} &Sigma;</div>
        </div>
      </a>
    </div>
  {/each}
</div>

<style global>
  .rowList {
    display: flex;
    flex-wrap: wrap;
    padding: 0 4px;
    justify-content: center;
  }

  div.gallery {
    padding: 2em;

    background-color: rgb(25, 27, 31);
    border: 2px solid rgb(25, 27, 31);
    border-radius: 16px;
    color: rgb(255, 255, 255);
  }

  div.gallery:hover {
    padding: 2em;
    /* background: rgb(220 218 224 / 20%); */
    background: rgb(33, 36, 41) !important;

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

  .responsiveItem {
    float: left;
    width: 24.99999%;
    margin: 1em;
  }

  @media only screen and (max-width: 700px) {
    .responsiveItem {
      width: 49.99999%;
      /* margin: 6px 0; */
    }
  }

  @media only screen and (max-width: 500px) {
    .responsiveItem {
      width: 100%;
    }
  }

  .clearfix:after {
    content: "";
    display: table;
    clear: both;
  }
</style>
