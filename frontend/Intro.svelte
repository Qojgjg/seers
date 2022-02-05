<script lang="ts">
  import logo from "./assets/logo-dark.svg"
  import { onMount } from "svelte"
  import { markets } from "canisters/markets"

  let ms: any = []
  let newMarketTitle: any = ""
  let newMarketDesc: any = ""
  let probYes: any = ""
  let probNo: any = ""
  let liquidity: any = ""

  const refreshMarkets = async () => {
    ms = await markets.readAll()
  }

  const deleteMarkets = async () => {
    await markets.deleteAll()
  }

  const createMarket = async () => {
    const market: any = {
      id: 0,
      title: newMarketTitle,
      description: newMarketDesc,
      yesProb: BigInt(probYes),
      noProb: BigInt(probNo),
      liquidity: BigInt(liquidity),
    }
    newMarketDesc = ""
    newMarketTitle = ""
    probYes = ""
    probNo = ""
    liquidity = ""
    await markets.create(market)
    refreshMarkets()
  }

  onMount(refreshMarkets)
</script>

<header class="App-header">
  <p style="font-size: 2em; margin-bottom: 0.5em">Seer</p>
  <div>
    <code>Prediction Markets</code>
  </div>
  <div style="display: flex; flex-wrap: wrap; padding: 0 4px;">
    {#each ms as market}
      <div
        style="min-width: 30%;  font-size: 0.7em;  padding: 2em; margin: 2em; border-radius: 30px;  background: rgb(220 218 224 / 25%);"
      >
        <div><img src="https://picsum.photos/100" alt="random" /></div>
        <div>
          #{market.id}
          <h3>{market.title}</h3>
        </div>
        <div style="padding: 2em;">{market.description}</div>
        <div>Yes probability: {market.yesProb / 100}</div>
        <div>No probability: {market.noProb / 100}</div>
        <div>Liquidity: {market.liquidity}</div>
      </div>
    {/each}
  </div>
  <div
    style="display:flex; float:left; flex-direction: column; margin: 2em; background-color: pink"
  >
    <div style="padding: 0.1em;"><h4 style="">Create new market</h4></div>
    <div style="padding: 1em; text-align:left">
      Title: <input bind:value={newMarketTitle} />
    </div>
    <div style="padding: 1em; text-align:left">
      Description: <input bind:value={newMarketDesc} />
    </div>
    <div style="padding: 1em; text-align:left">
      Probability Yes: <input bind:value={probYes} />
    </div>
    <div style="padding: 1em; text-align:left">
      Probability No: <input bind:value={probNo} />
    </div>
    <div style="padding: 1em; text-align:left">
      Liquidity: <input bind:value={liquidity} />
    </div>

    <button class="demo-button" on:click={createMarket}> Create Market </button>
  </div>
  <button class="demo-button" on:click={deleteMarkets}> Delete Markets </button>
</header>

<style global>
  .App-logo {
    height: 15vmin;
    pointer-events: none;
  }

  .App-header {
    margin-top: 150px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    font-size: calc(10px + 2vmin);
  }

  .App-link {
    color: rgb(26, 117, 255);
  }

  .demo-button {
    background: #a02480;
    padding: 0 1.3em;
    margin-top: 1em;
    border-radius: 60px;
    font-size: 0.7em;
    height: 35px;
    outline: 0;
    border: 0;
    cursor: pointer;
    color: white;
  }

  .demo-button:active {
    color: white;
    background: #979799;
  }
</style>
