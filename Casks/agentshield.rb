cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1148"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1148/agentshield_0.2.1148_darwin_amd64.tar.gz"
      sha256 "f9454a64cc7af223f8b6f55779586c899ad6e16ffca86353f32cf0e53df5468f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1148/agentshield_0.2.1148_darwin_arm64.tar.gz"
      sha256 "9a97e2b17678614774e5df5a5128c43333afb13ba5282bd3668721d166deb672"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1148/agentshield_0.2.1148_linux_amd64.tar.gz"
      sha256 "531c8c7ec901aa60a3e2459e07546cb521b377954a87b21560bef51976753ed2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1148/agentshield_0.2.1148_linux_arm64.tar.gz"
      sha256 "4bbea76c3a6a2d9f0845896c434e9c52a1d8031d36347ed6e85f46942026c8ac"
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
