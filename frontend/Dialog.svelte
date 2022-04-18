<script>
  import { getContext } from "svelte"

  export let title
  export let message
  export let onCancel = () => {}
  export let onOkay = () => {}

  const { close } = getContext("simple-modal")

  let onChange = () => {}

  function _onCancel() {
    onCancel()
    close()
  }

  function _onOkay() {
    onOkay()
    close()
  }

  $: onChange()
</script>

<h3>{title}</h3>

<div style="width: 100%; text-align: center">{message}</div>

<div class="buttons">
  <button class="btn-grad" on:click={_onCancel}> Cancel </button>
  <button class="btn-grad" on:click={_onOkay}> Okay </button>
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
