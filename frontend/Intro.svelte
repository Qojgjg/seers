<script lang="ts">
  import logo from "./assets/logo-dark.svg"
  import { onMount } from "svelte"
  import { markets } from "canisters/markets"

  let count: any = 0

  const refreshCounter = async () => {
    const market: any = {
      id: 0,
      title: "First market",
      description: "First market Description",
      outcomes: [],
    }
    const res: any = await markets.create(market)
    count = res.toString()
  }

  const increment = async () => {
    // await markets.increment()
    refreshCounter()
  }

  onMount(refreshCounter)
</script>

<header class="App-header">
  <p style="font-size: 2em; margin-bottom: 0.5em">Pythia</p>
  <div
    style="display: flex; font-size: 0.7em; text-align: left; padding: 2em; border-radius: 30px; flex-direction: column; background: rgb(220 218 224 / 25%);"
  >
    <div>
      <code>Prediction Markets</code>
    </div>
    <button class="demo-button" on:click={increment}>
      Markets: {count}
    </button>
  </div>
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
