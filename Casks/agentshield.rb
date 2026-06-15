cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1325"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1325/agentshield_0.2.1325_darwin_amd64.tar.gz"
      sha256 "3ae41ab5e1e71fe787539d8dcfd333b1d5887290468f90b9abb36ca6f86edb41"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1325/agentshield_0.2.1325_darwin_arm64.tar.gz"
      sha256 "4d95dae81779e208e8cab5155da312ef21f4c0c3172032f308ee00c014483fb0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1325/agentshield_0.2.1325_linux_amd64.tar.gz"
      sha256 "94434fd3e253264cb72744c4684875821b3fab87533bfc3c3d61b78109fc05f2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1325/agentshield_0.2.1325_linux_arm64.tar.gz"
      sha256 "50c9a6c59172203f09c9c5c84cd8d18e88bcde22076dfad33a1e1384f407b7fd"
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
