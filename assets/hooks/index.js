import * as Hello from "./build/dev/javascript/hooks/hello.mjs";
import { animate, createDraggable, createSpring } from "animejs";

SelectAllPermissions = {
  mounted() {
    this.el.addEventListener("change", (event) => {
      const groupId = this.el.dataset.groupId;
      const isChecked = event.target.checked;
      const checkboxes = document.querySelectorAll(
        `#access-group-permissions-${groupId} .permission-checkbox`,
      );
      checkboxes.forEach((checkbox) => {
        checkbox.checked = isChecked;
      });
    });
  },
};

SelectResourcePermissions = {
  mounted() {
    this.el.addEventListener("change", (event) => {
      const resource = this.el.dataset.resource;
      const groupId = this.el.dataset.groupId;
      const isChecked = event.target.checked;
      const checkboxes = document.querySelectorAll(
        `#access-group-permissions-${groupId} .permission-checkbox[data-resource="${resource}"]`,
      );
      checkboxes.forEach((checkbox) => {
        checkbox.checked = isChecked;
      });
    });
  },
};

AnimatedLogo = {
  mounted() {
    // Store references to DOM elements
    const $logo = this.el;
    const $button = document.querySelector("button");
    let rotations = 0;

    // Created a bounce animation loop
    animate($logo, {
      scale: [
        { to: 1.25, ease: "inOut(3)", duration: 200 },
        { to: 1, ease: createSpring({ stiffness: 300 }) },
      ],
      loop: true,
      loopDelay: 250,
    });

    // Make the logo draggable around its center
    createDraggable($logo, {
      container: [0, 0, 0, 0],
      releaseEase: createSpring({ stiffness: 200 }),
    });

    // Animate logo rotation on click
    const rotateLogo = () => {
      rotations++;
      $button.innerText = `rotations: ${rotations}`;
      animate($logo, {
        rotate: rotations * 360,
        ease: "out(4)",
        duration: 1500,
      });
    };

    // Add click event listener to button
    if ($button) {
      $button.addEventListener("click", rotateLogo);

      // Store the handler so we can remove it when the element is removed
      this.rotateLogo = rotateLogo;
    }
  },

  destroyed() {
    // Clean up event listeners when the element is removed
    const $button = document.querySelector("button");
    if ($button && this.rotateLogo) {
      $button.removeEventListener("click", this.rotateLogo);
    }
  },
};

export default { Hello, AnimatedLogo };
