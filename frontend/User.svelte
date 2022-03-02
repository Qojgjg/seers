<script lang="ts">
  import { onMount } from "svelte"

  import Header from "./Header.svelte"

  export let auth
  export let principal

  let user

  let getUserData = async () => {
    user = await $auth.actor.getUser(principal)
    console.log(user)
  }

  onMount(getUserData)
</script>

<Header />

<div class="UserBody">
  {#if user}
    <div>
      <div>User Id: {user.id}.</div>
      <div>Balance: {user.seerBalance} seers.</div>
      <div>
        Markets:
        {#each user.markets as market}
          <div>
            id {market.marketId} | {market.yesBalance} $yes | {market.noBalance}
            $no | {market.shares} shares
          </div>
        {/each}
      </div>
    </div>
  {:else}
    loading...
  {/if}
</div>

<style global>
  .UserBody {
    display: flex;
    justify-content: center;
  }
</style>
