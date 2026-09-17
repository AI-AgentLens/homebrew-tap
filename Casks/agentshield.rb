cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2163"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2163/agentshield_0.2.2163_darwin_amd64.tar.gz"
      sha256 "8d27ad6277d4636141eaab43153d26b01550a249e8fc2df3bf5b438a28842647"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2163/agentshield_0.2.2163_darwin_arm64.tar.gz"
      sha256 "9734c0c5120341fedbe1c65d8c82a563529fc151756b5ad8c0c95d103a0d1257"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2163/agentshield_0.2.2163_linux_amd64.tar.gz"
      sha256 "3dcc9e481b566e709ebd87c1042a2ccc9ef0eb1fc6fad8556bcdddfa4875678b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2163/agentshield_0.2.2163_linux_arm64.tar.gz"
      sha256 "98eb37b3793b194bcbbc62b035cc6b263ee8b300e7f58034b00737132544b9d2"
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
