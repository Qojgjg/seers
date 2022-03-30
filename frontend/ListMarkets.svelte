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
  <h2>Prediction Markets</h2>
</div>
<div class="rowList">
  {#each markets as market}
    <div class="responsiveItem">
      <a href="#/market/{market.id}">
        <div class="gallery">
          <div>
            <img src={market.imageUrl} alt="random" />
          </div>
          <div class="content">
            <h4 style="padding-top: 0;margin-top:0">{market.title}</h4>
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
              style="width: 100%; display: flex; flex-direction: row; font-size: 1em; padding-top: 5px"
            >
              <div style="width: 50%; ">Volume: {market.volume} &Sigma;</div>
              <div style="width: 50%">
                Liquidity: {market.liquidity} &Sigma;
              </div>
            </div>
          </div>
        </div>
      </a>
    </div>
  {/each}
</div>

<style global>
  .content {
    margin-left: 15px;
  }

  .rowList {
    display: flex;
    flex-wrap: wrap;
    padding: 0 4px;
    justify-content: center;
    width: 100%;
  }

  div.gallery {
    display: flex;
    padding: 2em;
    /* box-shadow: 0 0 1.5px 0.75px #fff, 0 0 2.5px 1.5px #f0f,
      0 0 3.5px 2.25px #0ff; */

    box-shadow: 2px 2px 20px 0.5px rgb(54, 27, 46);
    background-color: rgb(25, 27, 31);
    border: 2px solid rgb(25, 27, 31);
    border-radius: 16px;
    color: rgb(255, 255, 255);
  }

  div.gallery:hover {
    background: rgb(33, 36, 41) !important;
  }

  div.gallery img {
    max-width: 150px;
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
    width: 80%;
    max-width: 500px;
    margin: 1em;
  }

  @media only screen and (max-width: 1000px) {
    .responsiveItem {
      width: 80%;
    }
    .gallery {
      flex-direction: column;
    }

    .content {
      margin-left: 0;
      margin-top: 15px;
    }
  }

  .clearfix:after {
    content: "";
    display: table;
    clear: both;
  }
</style>
