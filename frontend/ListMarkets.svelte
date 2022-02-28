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
    <div
      style="width: 160px; font-size: 0.7em;  padding: 2em; margin: 2em; border-radius: 30px;  background: rgb(220 218 224 / 25%);"
    >
      <a href="#/market/{market.id}" style="text-decoration:none; color: black">
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
  .MarketList {
    display: flex;
    justify-content: center;
  }
</style>
