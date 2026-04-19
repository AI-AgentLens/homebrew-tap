cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.649"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.649/agentshield_0.2.649_darwin_amd64.tar.gz"
      sha256 "29766651b8f74d9095bd214c704a9b4249465eaa9771514acf851fb530a42f17"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.649/agentshield_0.2.649_darwin_arm64.tar.gz"
      sha256 "e971ac434f370c9a3c03b8bc790299b8bcc404c4c00f2c67f0259ad2d62ec05c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.649/agentshield_0.2.649_linux_amd64.tar.gz"
      sha256 "5d1aa2f04b0f6deb72d72a9ea9e80306d330e75951f3825e890b0daac29b133e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.649/agentshield_0.2.649_linux_arm64.tar.gz"
      sha256 "8d24aace83b1ad9daead69b572aadf112731ee5b4db5ba347a87e17e08fb6c7a"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
