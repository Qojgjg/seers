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
<div class="MarketDetails">
  {#if market}
    <div class="MarketHeader">
      <div class="MarketImage">
        <img src="https://picsum.photos/100" alt="random" />
      </div>
      <div class="MarketTitleDesc">
        <h3>{market.title}</h3>
        <p>{market.description}</p>
      </div>
      <div class="MarketControl">
        <div class="TabOptions">
          <div class="BuyTab">Buy</div>
          <div class="SellTab">Sell</div>
        </div>
        <div class="ContentTab">
          <div class="OutcomeTitle">Pick Outcome</div>
          <div class="YesNoOptions">
            <div class="BuyOpt">Yes</div>
            <div class="SellOpt">No</div>
          </div>
          <div class="OutcomeTitle">Seers Token Amount:</div>
          <div>
            $<input />
          </div>
          <div class="ControlData">
            <div>LP fee 0.30%</div>
            <div>Avg. price $1 seers</div>
            <div>Max. winnings $4000 seers</div>
          </div>
          <button>Send</button>
        </div>
      </div>
    </div>
  {:else}
    Loading
  {/if}
</div>

<style global>
  .ControlData {
    padding-top: 5em;
  }

  .OutcomeTitle {
    width: 100%;
    padding: 0.5em;
  }
  .YesNoOptions {
    width: 100%;
    display: flex;
    padding: 0.5em;
    height: fit-content;
    background-color: darkgray;
  }
  .TabOptions {
    width: 100%;
    display: flex;
    padding: 0.5em;
    height: fit-content;
    background-color: darkgray;
  }
  .ContentTab {
    background-color: gold;
    width: 100%;
  }
  .BuyOpt {
    width: 50%;
    height: fit-content;
    background-color: greenyellow;
  }
  .SellOpt {
    width: 50%;
    height: fit-content;
    background-color: red;
  }
  .BuyTab {
    width: 50%;
    height: fit-content;
    background-color: cyan;
  }
  .SellTab {
    width: 50%;
    height: fit-content;
    background-color: chocolate;
  }
  .MarketImage {
    padding: 2em;
    background-color: chartreuse;
  }
  .MarketControl {
    background-color: bisque;
    display: flex;
    flex-direction: column;
    padding: 2em;
    width: 200px;
    height: 400px;
  }
  .MarketTitleDesc {
    padding: 2em;
    width: 400px;
    background-color: cadetblue;
    justify-content: flex-start;
    align-items: flex-start;
  }
  .MarketDetails {
    display: flex;
    justify-content: center;
    align-items: flex-start;
  }

  .MarketHeader {
    display: flex;
    align-items: flex-start;
    justify-content: flex-start;
    text-align: start;
  }

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
