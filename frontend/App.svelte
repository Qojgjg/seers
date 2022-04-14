<script lang="ts">
  import { Router, Route, useNavigate, navigate } from "svelte-navigator"
  import icLogo from "./assets/ic.svg"
  import { auth, createActor } from "./store/auth"
  import ListMarkets from "./ListMarkets.svelte"
  import Auth from "./Auth.svelte"
  import ViewMarket from "./ViewMarket.svelte"
  import User from "./User.svelte"
  import CreateMarket from "./CreateMarket.svelte"
  import Ranking from "./Ranking.svelte"

  let principal = ""
  let marketIdSelected
  let signedIn = false

  const runAfterSign = (val, principal) => {
    signedIn = val
    principal = principal
  }
</script>

<Router>
  <div style="width: 100%; min-height: 80vh">
    <Auth {auth} signedInF={(val, p) => runAfterSign(val, p)} {createActor} />
    <Route path="market">
      <ViewMarket {auth} {signedIn} marketId={marketIdSelected} />
    </Route>
    <Route path="profile">
      <User {auth} {principal} />
    </Route>
    <Route path="create">
      <CreateMarket {auth} />
    </Route>
    <Route path="ranking">
      <Ranking {auth} />
    </Route>
    <Route path="/">
      <ListMarkets {auth} {principal} />
    </Route>
  </div>
  <footer
    style=" width: 100%; text-align: center; padding: 20px 0px; align-items:center; display: flex; flex-direction: column;justify-content: center; gap: 15px"
  >
    <div style="width: 50%;display:flex; justify-content:center">
      <img src={icLogo} alt="ic logo" style="max-width: 400px;" />
    </div>
    <div style="width: 50%;display:flex; justify-content:center;">
      <a href="https://twitter.com/SeerMarkets" class="grey"
        >Pense Technologies</a
      >
    </div>
  </footer>
</Router>

<style global>
  .grey {
    color: rgb(167, 165, 165);
  }
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
    background-color: #1b1c20;
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
