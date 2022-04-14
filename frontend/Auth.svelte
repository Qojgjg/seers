<script lang="ts">
  import { onMount } from "svelte"
  import { Router, Route, Link } from "svelte-navigator"
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

  function updateResponsive() {
    var x = document.getElementById("myTopnav")
    var classes = x.className.split(" ")
    if (classes.includes("responsive")) {
      //   navClass = "topnav responsive"
      // } else {
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
    updateResponsive()
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
    await client.logout()
    signedInF(false)
    signedIn = false
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

  function getProps({ location, href, isPartiallyCurrent, isCurrent }) {
    // const isActive = href === "/" ? isCurrent : isPartiallyCurrent || isCurrent

    // The object returned here is spread on the anchor element's attributes
    // if (isActive) {
    //   return { class: "active" }
    // }
    return { style: "padding: 5px" }
  }

  function getProps2({ location, href, isPartiallyCurrent, isCurrent }) {
    return { style: "padding: 5px", target: "_blank" }
  }

  onMount(initAuth)
</script>

<div class={navClass} id="myTopnav">
  <a
    href="/"
    class="left"
    style="margin: 0; padding: 0; margin-right: 20px; margin-left: 20px"
    ><img
      src={logo}
      alt="logo"
      style="width: 80px; align-content:center; text-align:center;"
    /></a
  >

  <Link to="/" {getProps}>Markets</Link>
  <Link to="ranking" {getProps}>Ranking</Link>
  <a href="https://forms.gle/fYmc9iTc9P46upm47">Bugs</a>

  {#if !signedIn && client}
    <div style="display: block; width:fit-content;float:right">
      <button
        on:click={signIn}
        style="color: white; background-color: transparent; font-size: 17px;"
        >Login</button
      >
    </div>
  {/if}

  {#if signedIn}
    <Link to="profile" {getProps}>Profile</Link>
    <Link to="create" {getProps}>Create</Link>
    <button
      on:click={signOut}
      style="color: white; background-color: transparent; font-size: 17px;"
      >Logout</button
    >
  {/if}
  <a href="javascript:void(0);" class="icon">
    <Fa icon={faBars} />
  </a>
</div>

<style>
  .button {
    background-color: transparent;
  }
  .topnav {
    display: flex;
    flex-direction: row;
    align-items: center;
  }

  .right {
    padding: 5px;
  }

  .topnav button:hover {
    cursor: pointer;
  }

  .topnav .icon {
    display: none;
    color: white;
    font-size: 1.2em;
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
    .topnav.responsive a.right {
      text-align: right;
      float: none;
      display: block;
    }
    .topnav.responsive a.left {
      float: none;
      display: block;
      text-align: left;
    }
    .topnav.responsive button {
      float: right;
      display: block;
      text-align: right;
    }
  }
</style>
