<script lang="ts">
  import { onMount } from "svelte"

  import Header from "./Header.svelte"

  export let auth
  export let principal

  let user

  let getUserData = async () => {
    user = await $auth.actor.getUserResult(principal)
    if (user) {
      user = user[0]
    }
    console.log(user)
  }

  let createUserData = async () => {
    user = await $auth.actor.createUserResult()
    console.log(user)
  }

  onMount(getUserData)
</script>

<Header />

<div class="UserBody">
  {#if user}
    <div>
      <div style="margin-bottom: 10px">User Id: {user.id}.</div>
      <div style="margin-bottom: 10px">Balance: {user.seerBalance} seers.</div>
      Markets:
      <div style="display:flex; flex-direction: column; ">
        {#each user.markets as market}
          <div
            style="display:flex; flex-direction: row; gap: 10px; margin-top: 10px"
          >
            <a href="#/market/{market.marketId}">
              * {market.marketTitle}
            </a>
            <div>
              {market.yesBalance} Yes
            </div>
            <div>
              {market.noBalance} No
            </div>
            <div>
              {market.shares} Shares.
            </div>
          </div>
        {/each}
      </div>
    </div>
  {:else}
    <button
      on:click={() => {
        createUserData()
      }}>Create User</button
    >
  {/if}
</div>

<style global>
  .UserBody {
    display: flex;
    justify-content: center;
  }
</style>
