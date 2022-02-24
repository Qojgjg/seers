<script lang="ts">
  import { onMount } from "svelte"
  import { auth, createActor } from "./store/auth"
  import Intro from "./Intro.svelte"
  import Auth from "./Auth.svelte"
  // import MarketItem from "./MarketItem.svelte"

  let item
  let page

  async function hashchange() {
    const path = window.location.hash.slice(1)

    if (path.startsWith("/market")) {
      const id = path.slice(6)
      // get market data
      window.scrollTo(0, 0)
    } else if (path.startsWith("/top")) {
      page = +path.slice(5)
      item = null
    } else {
      window.location.hash = "/top/1"
    }
  }
</script>

<svelte:window on:hashchange={hashchange} />

<main>
  {#if item}
    <div>Hello item</div>
  {:else}
    <div class="App">
      <Auth {auth} {createActor} />
      <Intro {auth} />
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
  }
</style>
