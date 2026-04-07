cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.443"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.443/agentshield_0.2.443_darwin_amd64.tar.gz"
      sha256 "dc4daebb9783ef7b899b39b2bd3ba331c7f6e74e7754055869c1508db5ac8ea5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.443/agentshield_0.2.443_darwin_arm64.tar.gz"
      sha256 "609dd14d9e406e0aa5ecf878c785463c2d69229ba90377b0c5a4b6a00860aa2f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.443/agentshield_0.2.443_linux_amd64.tar.gz"
      sha256 "fb57068cf05247af759ab17a769be6a1cbcefe893cddf703a42421a617faf73a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.443/agentshield_0.2.443_linux_arm64.tar.gz"
      sha256 "d8c74e9e5a76f9130ab4a978ad73029092bb6ec51b047167a29c5f57bae943be"
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
