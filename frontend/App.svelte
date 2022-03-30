<script lang="ts">
  import icLogo from "./assets/ic.svg"
  import { auth, createActor } from "./store/auth"
  import ListMarkets from "./ListMarkets.svelte"
  import Auth from "./Auth.svelte"
  import ViewMarket from "./ViewMarket.svelte"
  import User from "./User.svelte"
  import CreateMarket from "./CreateMarket.svelte"
  import Ranking from "./Ranking.svelte"

  let userPrincipal
  let marketIdSelected
  let page
  let signedIn = false

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
    } else if (path.startsWith("/ranking/")) {
      page = "ranking"
    } else {
      window.location.hash = ""
    }
  }
</script>

<svelte:window on:load={hashchange} on:hashchange={hashchange} />

<div style="width: 100%; min-height: 80vh">
  <Auth {auth} signedInF={(val) => (signedIn = val)} {createActor} />
  {#if page === "market"}
    <ViewMarket {auth} {signedIn} marketId={marketIdSelected} />
  {:else if page === "user"}
    <User {auth} principal={userPrincipal} />
  {:else if page === "create"}
    <CreateMarket {auth} />
  {:else if page === "ranking"}
    <Ranking {auth} />
  {:else}
    <ListMarkets {auth} />
  {/if}
</div>
<footer
  style=" width: 100%; text-align: center; padding: 20px 0px; align-items:center; display: flex; flex-direction: column;justify-content: center; gap: 15px"
>
  <div style="width: 50%;display:flex; justify-content:center">
    <img
      src={icLogo}
      alt="ic logo"
      style="height: 30px; width: 80%; max-width: 200px;"
    />
  </div>
  <div style="width: 50%;display:flex; justify-content:center;">
    Pense Technologies
  </div>
</footer>

<style global>
  a {
    text-decoration: none;
    color: white;
  }

  html {
    height: 100%;

    background: radial-gradient(
      50% 50% at 50% 50%,
      #fc077d10 0,
      rgba(255, 255, 255, 0) 100%
    );
    background-color: #212429;
  }

  body {
    margin: 0;
    color: whitesmoke;
    font-family: "Inter", sans-serif;

    /* font-family: Verdana, Geneva, Tahoma, sans-serif; */
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
  }

  button {
    /* font-weight: 600; */
    height: 49px;
  }

  .App {
    text-align: center;
    align-items: center;
    align-content: center;
    justify-content: center;
  }
</style>
