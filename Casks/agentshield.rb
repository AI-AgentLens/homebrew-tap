cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2168"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2168/agentshield_0.2.2168_darwin_amd64.tar.gz"
      sha256 "0aba20676c473bd27d93ac62a2f8df37e2c78d122615e21461003d7df5b0c777"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2168/agentshield_0.2.2168_darwin_arm64.tar.gz"
      sha256 "36cad052a6124921f2ffa1155b8a8d76caa5f079326ba60b7db9d8ca550fd25c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2168/agentshield_0.2.2168_linux_amd64.tar.gz"
      sha256 "b65cdad73a8265364e234bf1f379cbb344d00d3a88d7caad8a619d1fa1f2568e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2168/agentshield_0.2.2168_linux_arm64.tar.gz"
      sha256 "42f1f033cf46aea9a52a58da9ad99bf978b80a58752f10cb0dff3f40d260ae0d"
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
