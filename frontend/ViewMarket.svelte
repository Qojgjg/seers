<script lang="ts">
  import logo from "./assets/logo-dark.svg"
  import { onMount, beforeUpdate } from "svelte"
  import { identity } from "svelte/internal"
  import Header from "./Header.svelte"

  export let auth

  export let marketId

  let market
  let title
  let description
  //   let yesDeposit
  //   let noDeposit
  //   let endDate
  //   let liquidityToAdd
  //   let yesAmountToBuy
  //   let noAmountToBuy
  //   let yesAmountToSell
  //   let noAmountToSell

  const readMarket = async () => {
    market = await $auth.actor.readMarket(parseInt(marketId))
    market = market[0]
    console.log(market)
  }

  onMount(readMarket)
</script>

<Header />
{#if market}
  <a href="#/market/{market.id}" style="text-decoration:none; color: black">
    <div>
      <img src="https://picsum.photos/100" alt="random" />
      <h3>{market.title}</h3>
    </div>
  </a>
{:else}
  Loading
{/if}

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
