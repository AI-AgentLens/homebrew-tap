cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.88"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.88/agentshield_0.2.88_darwin_amd64.tar.gz"
      sha256 "4b3a34d29bd304221a1157430988502f46d43d4f1745c7fdeb5109465dff6da0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.88/agentshield_0.2.88_darwin_arm64.tar.gz"
      sha256 "5cb4e163d61d7f969fae299c00f95a6f970d2435e2c915014680294d9c52985b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.88/agentshield_0.2.88_linux_amd64.tar.gz"
      sha256 "92a5c583e6494c07a20fd6df7e017714b22e66a63bf0904a6c2126677f03e461"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.88/agentshield_0.2.88_linux_arm64.tar.gz"
      sha256 "96cfe5e0f61c1fd06e50cbc824d178e2624e6c8beb57e803f17286ff0d1ee8bf"
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
