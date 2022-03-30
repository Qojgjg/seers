<script lang="ts">
  import { onMount } from "svelte"
  import { AuthClient } from "@dfinity/auth-client"
  import Fa from "svelte-fa"
  import { faBars } from "@fortawesome/free-solid-svg-icons"
  import logo from "./assets/favicon.png"

  export let auth
  export let createActor
  export let signedInF

  let signedIn = false

  /** @type {AuthClient} */
  let client
  let principal = ""
  let navClass = "topnav"

  function myFunction() {
    var x = document.getElementById("myTopnav")
    var classes = x.className.split(" ")
    console.log(classes)
    if (!classes.includes("responsive")) {
      console.log("responsive")
      navClass = "topnav responsive"
    } else {
      console.log("no responsive")
      navClass = "topnav"
    }
  }
  const initAuth = async () => {
    client = await AuthClient.create()
    if (await client.isAuthenticated()) {
      handleAuth()
    }
  }

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
    principal = client.getIdentity().getPrincipal()
    signedInF(true)
    signedIn = true
  }

  const signIn = () => {
    client.login({
      identityProvider: "http://rwlgt-iiaaa-aaaaa-aaaaa-cai.localhost:8000/",
      // identityProvider: "https://identity.ic0.app/",
      onSuccess: handleAuth,
    })
  }

  const signOut = async () => {
    myFunction()
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

<div class={navClass} id="myTopnav">
  <a
    href="/"
    class="active"
    style="margin: 0; padding: 0; margin-right: 20px; margin-left: 20px"
    ><img
      src={logo}
      alt="logo"
      style="width: 80px; align-content:center; text-align:center;"
    /></a
  >
  <a href="/" class="active" style="margin-top: 5px">Markets</a>
  <a href="#/ranking/" class="active" style="margin-top: 5px">Ranking</a>

  {#if !signedIn && client}
    <button on:click={signIn} style="margin-top: 5px">Login</button>
  {/if}

  {#if signedIn}
    <a href="#/user/{principal}" on:click={myFunction} style="margin-top: 5px"
      >Profile</a
    >
    <a href="#/create/" on:click={myFunction} style="margin-top: 5px">Create</a>
    <button on:click={signOut} style="margin-top: 5px">Logout</button>
  {/if}
  <a href="javascript:void(0);" class="icon" on:click={myFunction}>
    <Fa icon={faBars} />
  </a>
</div>

<style>
  .topnav a {
    float: left;
    display: block;
    color: #f2f2f2;
    text-align: center;
    padding: 14px 16px;
    text-decoration: none;
    font-size: 17px;
  }

  .topnav button {
    float: left;
    display: block;
    color: #f2f2f2;
    text-align: center;
    text-decoration: none;
    font-size: 17px;
    padding: 14px 16px;
    border: none;
    background: none;
  }

  .topnav button:hover {
    cursor: pointer;
  }

  .topnav .icon {
    display: none;
    color: white;
  }

  @media screen and (max-width: 600px) {
    .topnav a:not(:first-child) {
      display: none;
    }
    .topnav button:not(:first-child) {
      display: none;
    }
    .topnav a.icon {
      float: right;
      display: block;
      color: white;
    }
  }

  @media screen and (max-width: 600px) {
    .topnav.responsive .icon {
      position: absolute;
      right: 0;
      top: 0;
      color: white;
    }
    .topnav.responsive a {
      float: none;
      display: block;
      text-align: left;
    }
    .topnav.responsive button {
      float: none;
      display: block;
      text-align: left;
    }
  }
</style>
