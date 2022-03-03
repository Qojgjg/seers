<script lang="ts">
  import { onMount } from "svelte"
  import { AuthClient } from "@dfinity/auth-client"
  import dfinityLogo from "./assets/dfinity.svg"

  export let auth
  export let createActor

  let signedIn = false
  /** @type {AuthClient} */
  let client
  let principal = ""

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
    signedIn = true
  }

  const signIn = () => {
    client.login({
      identityProvider: "http://rno2w-sqaaa-aaaaa-aaacq-cai.localhost:8000/",
      onSuccess: handleAuth,
    })
  }

  const signOut = async () => {
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

<div class="Wrapper">
  <div class="auth-section">
    <div style="font-size: 2em; width: 50%">
      <a href="/" style="float: left; text-decoration: none;">Seers</a>
    </div>

    <div style="width: 50%;">
      <div style="float: right;">
        <a href="/" class="MenuLink">Home</a>

        {#if !signedIn && client}
          <button on:click={signIn} class="auth-button">
            Sign In
            <img alt="" style="width: 33px;" src={dfinityLogo} />
          </button>
        {/if}

        {#if signedIn}
          <a href="#/user/{principal}" class="MenuLink">My Profile</a>
          <a href="#/create/" class="MenuLink">Create New Market</a>
          <button on:click={signOut} class="auth-button">Sign out</button>
        {/if}
      </div>
    </div>
  </div>
</div>

<style>
  .Wrapper {
    background-color: black;
    display: flex;
    justify-content: center;
  }
  .MenuLink {
    padding: 20px;
    font-size: 1em;
  }

  .auth-section {
    padding: 1em;
    display: flex;
    width: 100%;
    position: fixed;
    top: 0;
    width: 80%;
    max-width: 1000px;
  }

  .auth-button {
    color: white;
    background: black;
    padding: 0 2em;
    border-radius: 60px;
    font-size: 1em;
    height: 33px;
    border: 0;
    align-items: center;
    text-align: center;
    border-color: white;
    cursor: pointer;
    text-decoration: none;
  }
</style>
