<script lang="ts">
  import icLogo from "./assets/ic.svg"
  import { auth, createActor } from "./store/auth"
  import ListMarkets from "./ListMarkets.svelte"
  import Auth from "./Auth.svelte"
  import ViewMarket from "./ViewMarket.svelte"
  import User from "./User.svelte"
  import CreateMarket from "./CreateMarket.svelte"

  let userPrincipal
  let marketIdSelected
  let page

  async function hashchange() {
    const path = window.location.hash.slice(1)
    if (path.startsWith("/market/")) {
      page = "market"
      marketIdSelected = path.slice(8)
      window.scrollTo(0, 0)
    } else if (path.startsWith("/user/")) {
      page = "user"
      userPrincipal = path.slice(6)
    } else if (path.startsWith("/create/")) {
      page = "create"
    } else {
      window.location.hash = ""
    }
  }
</script>

<svelte:window on:load={hashchange} on:hashchange={hashchange} />

<main>
  <Auth {auth} {createActor} />
  {#if page === "market"}
    <ViewMarket {auth} marketId={marketIdSelected} />
  {:else if page === "user"}
    <User {auth} principal={userPrincipal} />
  {:else if page === "create"}
    <CreateMarket {auth} />
  {:else}
    <div class="App">
      <ListMarkets {auth} />
    </div>
  {/if}
  <footer
    style="width: 100%; text-align: center; padding: 50px 0px; align-items:center; display: flex; justify-content: center; gap: 15px"
  >
    <img src={icLogo} alt="ic logo" style="height: 30px" />Pensen Tech
  </footer>
</main>

<style global>
  a {
    text-decoration: none;
    color: white;
  }
  body {
    margin: 0;
    background-color: rgba(0, 0, 0, 0.9);
    color: whitesmoke;
    font-family: Verdana, Geneva, Tahoma, sans-serif;
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
