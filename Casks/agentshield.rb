cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2170"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2170/agentshield_0.2.2170_darwin_amd64.tar.gz"
      sha256 "4b924bbedc11305a6773cad107d50a1162a87c82d49b535b58769414bc90d69f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2170/agentshield_0.2.2170_darwin_arm64.tar.gz"
      sha256 "b21dccd611958c6ec1a8fa083a5a2eed41ba73b45e2e9284ffe9bdd56f1c4b36"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2170/agentshield_0.2.2170_linux_amd64.tar.gz"
      sha256 "f74f23a27175c0955462702bbf54e3adddecb953a0f3db2d2ee3e6b78be5b604"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2170/agentshield_0.2.2170_linux_arm64.tar.gz"
      sha256 "f87c56c80678c5dde0d7c52897078a436f13f7329f31443248ab596493746b98"
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
