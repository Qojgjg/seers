<script lang="ts">
  import { Router, Route, useNavigate } from "svelte-navigator"
  import { AuthClient } from "@dfinity/auth-client"

  import { onMount } from "svelte"
  import icLogo from "./assets/ic.svg"
  import { auth, createActor } from "./store/auth"
  import ListMarkets from "./ListMarkets.svelte"
  import Auth from "./Auth.svelte"
  import ViewMarket from "./ViewMarket.svelte"
  import Wallet from "./Wallet.svelte"
  import CreateMarket from "./CreateMarket.svelte"
  import Ranking from "./Ranking.svelte"
  import Feed from "./Feed.svelte"
  import Profile from "./Profile.svelte"
  import ViewPost from "./ViewPost.svelte"

  let principal = ""

  /** @type {AuthClient} */
  let client

  function handleAuth() {
    auth.update(() => ({
      loggedIn: true,
      actor: createActor({
        agentOptions: {
          identity: client.getIdentity(),
        },
        actorOptions: {
          identity: client.getIdentity(),
        },
      }),
    }))
    principal = client.getIdentity().getPrincipal().toText()
  }

  const initAuth = async () => {
    client = await AuthClient.create()
    if (await client.isAuthenticated()) {
      handleAuth()
    }
  }

  const signIn = () => {
    if (client)
      client.login({
        identityProvider: "http://rwlgt-iiaaa-aaaaa-aaaaa-cai.localhost:8000/",
        // identityProvider: "https://identity.ic0.app/",
        onSuccess: handleAuth,
      })
  }

  const signOut = async () => {
    principal = ""
    await client.logout()
    auth.update(() => ({
      loggedIn: false,
      actor: createActor({
        agentOptions: {
          identity: client.getIdentity(),
        },
        actorOptions: {
          identity: client.getIdentity(),
        },
      }),
    }))
  }

  onMount(initAuth)
</script>

<svelte:head>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link
    href="https://fonts.googleapis.com/css2?family=Manrope&family=Roboto&family=Roboto+Mono&family=Poppins&display=swap"
    rel="stylesheet"
  />
</svelte:head>

<Router>
  <div style="width: 100%; min-height: 80vh">
    <Auth {principal} {signIn} {signOut} />
    <Route path="market/:id" let:params>
      <ViewMarket {auth} {principal} {signIn} id={params.id} />
    </Route>
    <Route path="wallet">
      <Wallet {auth} {principal} {signIn} />
    </Route>
    <Route path="profile" let:params>
      <Profile {auth} {principal} {signIn} />
    </Route>
    <Route path="profile/:handle" let:params>
      <Profile {auth} handle={params.handle} {principal} {signIn} />
    </Route>
    <Route path="post/:id" let:params primary={false}>
      <ViewPost {auth} id={params.id} {principal} {signIn} />
    </Route>
    <Route path="create">
      <CreateMarket {auth} {principal} {signIn} />
    </Route>
    <Route path="ranking">
      <Ranking {auth} />
    </Route>
    <Route path="feed" primary={false}>
      <Feed {auth} {principal} {signIn} />
    </Route>
    <Route path="markets">
      <ListMarkets {auth} />
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
    scroll-behavior: smooth;
    height: 100%;
    /* color: black; */
    background-color: black;
  }

  body {
    margin: 0;
    color: whitesmoke;
    /* font-family: "Inter", sans-serif; */
    font-family: "Poppins", sans-serif;
    /* font-family: "Roboto", sans-serif; */

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
