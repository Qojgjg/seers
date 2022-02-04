<script lang="ts">
  import logo from "./assets/logo-dark.svg"
  import { onMount } from "svelte"
  import { markets } from "canisters/markets"

  let count: any = 0
  let ms: any = []
  let newMarket: any = ""

  const refreshMarkets = async () => {
    ms = await markets.readAll()
  }

  const increment = async () => {
    const market: any = {
      id: 0,
      title: newMarket,
      description: "First market Description",
      outcomes: [],
    }
    const res: any = await markets.create(market)
    count = res.toString()
    refreshMarkets()
  }

  onMount(refreshMarkets)
</script>

<header class="App-header">
  <p style="font-size: 2em; margin-bottom: 0.5em">Pythia</p>
  <div>
    <code>Prediction Markets</code>
  </div>
  <div
    style="display: flex; font-size: 0.7em; text-align: left; padding: 2em; border-radius: 30px; flex-direction: column; background: rgb(220 218 224 / 25%);"
  >
    <h3>Markets</h3>
    <ol>
      {#each ms as market}
        <li>{market.title}</li>
      {/each}
    </ol>
  </div>

  <input bind:value={newMarket} />
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
