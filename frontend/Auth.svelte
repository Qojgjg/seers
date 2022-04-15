<script lang="ts">
  import { Link } from "svelte-navigator"
  import Fa from "svelte-fa"
  import { faBars } from "@fortawesome/free-solid-svg-icons"
  import logo from "./assets/favicon.png"
  import { onMount } from "svelte"

  export let principal
  export let signOut
  export let signIn

  let innerWidth = window.innerWidth
  let navStyle = "display: flex; flex-direction: row; align-items: center"
  let common =
    ";background-color: transparent; font-size: 17px; padding: 5px; height: fit-content;"
  let menuItemStyle = ""
  let logoStyle = ""

  $: if (innerWidth < 600) {
    menuItemStyle = "color: red; display: none; text-align: center" + common
  } else {
    menuItemStyle = "color: blue; text-align: center" + common
  }

  function openMenu() {
    navStyle = "display: flex; flex-direction: column; align-items: center"
    menuItemStyle =
      "color: green; display: block; width: 100%; text-align: right; margin-right: 15px" +
      common
  }
</script>

<svelte:window bind:innerWidth />

{innerWidth}

<div style={navStyle}>
  <a
    href="/"
    style="margin: 0; padding: 0; margin-right: 20px; margin-left: 20px"
    ><img
      src={logo}
      alt="logo"
      style="width: 80px; align-content:center; text-align:center;"
    /></a
  >

  <Link to="/" style={menuItemStyle}>Markets</Link>
  <Link to="ranking" style={menuItemStyle}>Ranking</Link>

  {#if principal === ""}
    <a href="https://forms.gle/fYmc9iTc9P46upm47" style={menuItemStyle}>Bugs</a>
    <button on:click={signIn} style={menuItemStyle}>Login</button>
  {/if}

  {#if principal !== ""}
    <Link to="profile" style={menuItemStyle}>Profile</Link>
    <Link to="create" style={menuItemStyle}>Create</Link>
    <a href="https://forms.gle/fYmc9iTc9P46upm47" style={menuItemStyle}>Bugs</a>

    <button on:click={signOut} style={menuItemStyle}>Logout</button>
  {/if}
  <a href="javascript:void(0);" class="icon" on:click={openMenu}>
    <Fa icon={faBars} />
  </a>
</div>

<style>
  button:hover {
    cursor: pointer;
  }

  .icon {
    display: none;
    color: white;
    font-size: 1.2em;
  }

  @media screen and (max-width: 600px) {
    /* .topnav a.icon {
      float: right;
      display: block;
      color: white;
    } */
    .icon {
      position: absolute;
      display: block;
      padding: 10px;
      right: 0;
      top: 0;
      color: white;
    }
    /* .topnav.responsive a {
      text-align: right;
      float: none;
      display: block;
    } */
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
