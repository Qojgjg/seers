<script lang="ts">
  import { onMount } from "svelte"
  import { select_multiple_value } from "svelte/internal"

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
          <h3>{market.title}</h3>
          <div style="margin-top: 10px; margin-bottom: 10px">
            {#each market.labels as label, i}
              <div style="width: 100%; display: flex; font-size: 1.2em;">
                <div style="width: 50%">{label}</div>
                <div style="width: 50%">
                  {(Number(market.probabilities[i]) / 1000.0).toFixed(2)} &Sigma;
                </div>
              </div>
            {/each}
          </div>
          <div
            style="width: 100%; display: flex; flex-direction: row; font-size: 1.2em; padding-top: 5px"
          >
            <div style="width: 50%; ">Volume: {market.volume} &Sigma;</div>
            <div style="width: 50%">
              Liquidity: {market.liquidity} &Sigma;
            </div>
          </div>
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
    width: 40%;
    max-width: 500px;
    margin: 1em;
  }

  @media only screen and (max-width: 1000px) {
    .responsiveItem {
      width: 80%;
    }
  }

  /* @media only screen and (max-width: 500px) {
    .responsiveItem {
      width: 80%;
    }
  } */

  .clearfix:after {
    content: "";
    display: table;
    clear: both;
  }
</style>
