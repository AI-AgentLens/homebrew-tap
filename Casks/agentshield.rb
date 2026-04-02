cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.310"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.310/agentshield_0.2.310_darwin_amd64.tar.gz"
      sha256 "a6e05ba38c498cfa0f846f67a1c08d3279e92be6e33ba633e5d04eb7d2249d7e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.310/agentshield_0.2.310_darwin_arm64.tar.gz"
      sha256 "c672a22b29bd59704c2737daeeb0923fb5d2e5355b5f5704c1c38f15f0cf567d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.310/agentshield_0.2.310_linux_amd64.tar.gz"
      sha256 "d6a4959b87fe0705e7bff15b26636532719dddad6ec5a95d4682f3b8485c426a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.310/agentshield_0.2.310_linux_arm64.tar.gz"
      sha256 "795d0673433d246cefc0697b860dad22c5c1cf84aad0ee35742402f503271487"
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
