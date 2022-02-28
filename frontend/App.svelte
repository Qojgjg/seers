<script lang="ts">
  import { auth, createActor } from "./store/auth"
  import ListMarkets from "./ListMarkets.svelte"
  import Auth from "./Auth.svelte"
  import ViewMarket from "./ViewMarket.svelte"

  let marketIdSelected

  async function hashchange() {
    const path = window.location.hash.slice(1)
    console.log("path: " + path)
    if (path.startsWith("/market/")) {
      marketIdSelected = path.slice(8)
      console.log("market selected " + marketIdSelected)
      window.scrollTo(0, 0)
    }
  }
</script>

<svelte:window on:hashchange={hashchange} />

<main>
  <Auth {auth} {createActor} />
  {#if marketIdSelected}
    <ViewMarket {auth} marketId={marketIdSelected} />
  {:else}
    <div class="App">
      <ListMarkets {auth} />
    </div>
  {/if}
</main>

<style global>
  body {
    margin: 0;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto",
      "Oxygen", "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans",
      "Helvetica Neue", sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
  }

  button {
    font-weight: 600;
  }

  .App {
    text-align: center;
    align-items: center;
    align-content: center;
    justify-content: center;
  }
</style>
