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

<div class="auth-section">
  {#if !signedIn && client}
    <button on:click={signIn} class="auth-button">
      Sign In
      <img
        alt=""
        style="width: 33px; margin-right: -1em; margin-left: 0.7em;"
        src={dfinityLogo}
      />
    </button>
  {/if}

  {#if signedIn}
    <p>Signed in as: {principal}</p>
    <button on:click={signOut} class="auth-button">Sign out</button>
  {/if}
</div>

<style>
  .auth-section {
    padding: 1em;
    display: flex;
    justify-content: flex-end;
    align-items: center;
    text-align: right;
    position: fixed;
    top: 0;
    right: 0;
  }

  .auth-button {
    color: black;
    background: white;
    padding: 0 2em;
    border-radius: 60px;
    font-size: 1em;
    line-height: 40px;
    height: 33px;
    outline: 0;
    border: 0;
    cursor: pointer;
    text-decoration: underline;
    display: flex;
    align-items: center;
  }
</style>
