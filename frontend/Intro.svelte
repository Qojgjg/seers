<script lang="ts">
  import logo from "./assets/logo-dark.svg"
  import { onMount } from "svelte"
  import { markets } from "canisters/markets"

  let ms: any = []
  let newMarketTitle: any = ""
  let newMarketDesc: any = ""

  const refreshMarkets = async () => {
    ms = await markets.readAll()
  }

  const increment = async () => {
    const market: any = {
      id: 0,
      title: newMarketTitle,
      description: newMarketDesc,
      outcomes: [],
    }
    const res: any = await markets.create(market)
    const _ = res.toString()
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
        style="max-width: 30%;  font-size: 0.7em;  padding: 2em; margin: 2em; border-radius: 30px;  background: rgb(220 218 224 / 25%);"
      >
        <div><img src="https://picsum.photos/100" alt="random" /></div>
        <div>
          #{market.id}
          <h3>{market.title}</h3>
        </div>
        <div>{market.description}</div>
      </div>
    {/each}
  </div>
  <input bind:value={newMarketTitle} />
  <input bind:value={newMarketDesc} />
  <button class="demo-button" on:click={increment}> Create Market </button>
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
