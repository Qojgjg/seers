<script lang="ts">
  import { onMount } from "svelte"

  export let auth
  export let principal
  export let signIn

  const fetchInfo = async () => {
    let balance = await $auth.actor.canisterBalance()
    console.log("Balance = " + balance["e8s"])
    let account = await $auth.actor.canisterAccount()
    console.log("Account = " + account)
    let otherAccount = await $auth.actor.otherAccount()
    console.log("Other Account = " + otherAccount)
    let otherBalance = await $auth.actor.otherBalance()
    console.log("Other Balance = " + otherBalance["e8s"])
  }

  const sentToSeers = async () => {
    let resp = await $auth.actor.transferToCanister()
    console.log(resp)
  }

  const sentToUser = async () => {
    let resp = await $auth.actor.transferToSubaccount()
    console.log(resp)
  }

  onMount(fetchInfo)
</script>

<div style="display:flex; width: 100%; justify-content:center">
  <div class="rowUser">
    <button class="btn-grad" on:click={sentToSeers}>Transfer to Seers</button>
    <button class="btn-grad" on:click={sentToUser}>Transfer to User</button>
  </div>
</div>
