<script lang="ts">
  import { onMount } from "svelte"

  const PAGE_SIZE = 20

  export let auth

  let markets = []
  let openMarkets = []
  let resolvedMarkets = []
  let categorySelected = "any"
  let stateSelected = "any"

  const runOnMount = async () => {
    let category = {}
    let state = {}
    category[categorySelected] = null
    state[stateSelected] = null
    console.log(category)
    console.log(state)
    markets = await $auth.actor.readAllMarkets(category, state)
  }

  const printFloat = (x) => {
    if (x > 10000) {
      return (Number(x) / 1000.0).toFixed(0) + "k"
    } else {
      return Number(x).toFixed(0)
    }
  }

  onMount(runOnMount)
</script>

<div class="header">
  <h3>Prediction Markets</h3>
</div>
<div
  style="width: 100%; text-align:center;display: flex; justify-content:center; padding: 30px;"
>
  <div style="margin-right: 30px;">
    <select bind:value={categorySelected} on:change={runOnMount}>
      <option value="any">All</option>
      <option value="crypto">Crypto</option>
      <option value="sports">Sports</option>
      <option value="politics">Politics</option>
      <option value="entertainment">Entertainment</option>
      <option value="science">Science</option>
      <option value="business">Business</option>
      <option value="finance">Finance</option>
      <option value="seers">Seers</option>
      <option value="dfinity">Internet Computer</option>
      <option value="self">Self Referential</option>
    </select>
  </div>
  <div>
    <select bind:value={stateSelected} on:change={runOnMount}>
      <option value="any">All</option>
      <option value="pending">Pending</option>
      <option value="approved">Approved</option>
      <option value="open">Open</option>
      <option value="closed">Closed</option>
      <option value="resolved">Resolved</option>
      <option value="invalid">Invalid</option>
    </select>
  </div>
</div>
<div class="rowList">
  {#each markets as market}
    {#if !market.state["resolved"]}
      <div class="responsiveItem">
        <a href="market/{market.id}">
          <div class="gallery">
            <div>
              <img src={market.imageUrl} alt="random" />
            </div>
            <div class="content">
              <h4 style="padding-top: 0;margin-top:0">
                {market.title}
              </h4>
              <div
                style="margin-top: 10px; margin-bottom: 10px; max-height: 80px; overflow:hidden;"
              >
                {#each market.labels as label, i}
                  <div style="width: 100%; display: flex; font-size: 1.2em;">
                    <div style="width: 50%">{label}</div>
                    <div style="width: 50%">
                      {Number(market.probabilities[i]).toFixed(2)} &Sigma;
                    </div>
                  </div>
                {/each}
              </div>
              <div
                style="width: 100%; display: flex; flex-direction: row; font-size: 1em; padding-top: 5px"
              >
                <div style="width: 50%; ">
                  Volume: {printFloat(market.volume)} &Sigma;
                </div>
                <div style="width: 50%">
                  Liquidity: {printFloat(market.liquidity)} &Sigma;
                </div>
              </div>
            </div>
          </div>
        </a>
      </div>
    {:else}
      <div class="responsiveItem">
        <a href="market/{market.id}">
          <div class="gallery">
            <div>
              <img
                src={market.imageUrl}
                alt="random"
                style="filter: brightness(50%);"
              />
            </div>
            <div class="content-resolved">
              <h4 style="padding-top: 0;margin-top:0">
                {market.title}
                <span style="color: hotpink;">
                  Resolved to {market.labels[market.state["resolved"]].slice(
                    0,
                    20,
                  )}
                </span>
              </h4>
              <div
                style="margin-top: 10px; margin-bottom: 10px; max-height: 80px; overflow:hidden;"
              >
                {#each market.labels as label, i}
                  <div style="width: 100%; display: flex; font-size: 1.2em;">
                    <div style="width: 50%">{label}</div>
                    <div style="width: 50%">
                      {Number(market.probabilities[i]).toFixed(2)} &Sigma;
                    </div>
                  </div>
                {/each}
              </div>
              <div
                style="width: 100%; display: flex; flex-direction: row; font-size: 1em; padding-top: 5px"
              >
                <div style="width: 50%; ">
                  Volume: {printFloat(market.volume)} &Sigma;
                </div>
                <div style="width: 50%">
                  Liquidity: {printFloat(market.liquidity)} &Sigma;
                </div>
              </div>
            </div>
          </div>
        </a>
      </div>
    {/if}
  {/each}
</div>

<style>
  .content {
    margin-left: 15px;
    width: 100%;
    min-height: 170px;
  }
  .content-resolved {
    margin-left: 15px;
    width: 100%;
    color: grey;
    min-height: 170px;
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
    border: 1px solid rgb(90, 58, 81);
    border-radius: 16px;
    color: rgb(255, 255, 255);
  }

  div.gallery:hover {
    background: rgb(33, 36, 41) !important;
  }

  img {
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

    .content-resolved {
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
