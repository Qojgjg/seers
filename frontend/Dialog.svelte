<script>
  import { getContext } from "svelte"

  export let title
  export let message
  export let onCancel = () => {}
  export let onOkay = () => {}

  const { close } = getContext("simple-modal")

  let response = null
  let okLabel = "Okay"
  let onChange = () => {}

  function _onCancel() {
    onCancel()
    close()
  }

  async function _onOkay() {
    okLabel = "Processing..."
    response = await onOkay()
    console.log("response: " + response)
  }

  $: onChange()
</script>

<h3>{title}</h3>

{#if !response}
  <div style="width: 100%; text-align: center">{message}</div>
{/if}
{#if response && response.length == 2}
  <div style="width: 100%; text-align: center">
    {response[0] ? response[0] : "Transaction successful!"}
  </div>
{/if}

<div class="buttons">
  <button class="btn-grad" on:click={_onCancel}> Close</button>
  {#if !response}
    <button class="btn-grad" on:click={_onOkay}>{okLabel}</button>
  {/if}
</div>

<style>
  h3 {
    text-align: center;
  }

  input {
    width: 100%;
  }

  .buttons {
    display: flex;
    width: 100%;
    justify-content: space-around;
  }
</style>
