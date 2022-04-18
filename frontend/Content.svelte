<script>
  import { getContext } from "svelte"
  import Dialog from "./Dialog.svelte"

  export let onOk
  export let tokensEstimate
  export let outcome
  export let seerAmount

  const { open } = getContext("simple-modal")

  let opening = false
  let opened = false
  let closing = false
  let closed = false

  let name
  let status = 0

  const onCancel = () => {
    name = ""
    status = -1
  }

  const onOkay = () => {
    onOk()
    status = 1
  }

  const showDialog = () => {
    open(
      Dialog,
      {
        title: "Confirm Transaction",
        message: `Buying ${tokensEstimate.toFixed(
          2,
        )} shares of "${outcome}". Total cost is ${Number(seerAmount).toFixed(
          2,
        )} Σ`,
        hasForm: true,
        onCancel,
        onOkay,
      },
      {
        closeButton: false,
        closeOnEsc: false,
        closeOnOuterClick: false,
      },
    )
  }
</script>

<section>
  <button class="btn-grad" on:click={showDialog}>Buy Yes</button>

  {#if status === 1}
    <p style="color: green">Done!</p>
  {:else if status === -1}
    <p style="color: red">Transaction was canceled</p>
  {/if}

  <div id="state">
    {#if opening}
      <p>opening modal...</p>
    {:else if opened}
      <p>opened modal!</p>
    {:else if closing}
      <p>closing modal...</p>
    {:else if closed}
      <p>closed modal!</p>
    {/if}
  </div>
</section>

<style>
  section {
    padding-top: 0.5em;
  }

  #state {
    position: absolute;
    top: 0;
    right: 0;
    opacity: 0.33;
    font-size: 0.8em;
  }
</style>
