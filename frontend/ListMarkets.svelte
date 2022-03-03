<script lang="ts">
  import { onMount } from "svelte"
  import Header from "./Header.svelte"

  const PAGE_SIZE = 20

  export let auth

  let markets = []

  const refreshMarkets = async () => {
    markets = await $auth.actor.readAllMarkets()
  }

  onMount(refreshMarkets)
</script>

<Header />

<div class="MarketList">
  {#each markets as market}
    <div class="MarketItem">
      <a href="#/market/{market.id}">
        <div>
          <img src="https://picsum.photos/100" alt="random" />
          <h3>{market.title}</h3>
        </div>
      </a>
      <div>Yes: {market.yesProb}%</div>
      <div>No: {market.noProb}%</div>
    </div>
  {/each}
</div>

<style global>
  .MarketItem {
    width: 160px;
    padding: 2em;
    margin: 2em;
    border-radius: 20px;
    background: rgb(220 218 224 / 25%);
  }
  .MarketList {
    display: flex;
    justify-content: center;
  }
</style>
