cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1444"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1444/agentshield_0.2.1444_darwin_amd64.tar.gz"
      sha256 "c3cd8ecb124a0f29e91d70a813a346a6f5cebb033ac65a417b292ff65272db2f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1444/agentshield_0.2.1444_darwin_arm64.tar.gz"
      sha256 "313aa907c504479c5542fe3d4e47cc0a595169f03a44edcc8e7b717247db9161"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1444/agentshield_0.2.1444_linux_amd64.tar.gz"
      sha256 "3c3ca29153e123ba6af2194c27e142ea6e550032def25f98cc9b438aee823df4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1444/agentshield_0.2.1444_linux_arm64.tar.gz"
      sha256 "1728b929b710234369d8ead1eec3b230b3b569b64fa9a59588ed3004a62cd039"
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
