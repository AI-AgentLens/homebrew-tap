cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2301"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2301/agentshield_0.2.2301_darwin_amd64.tar.gz"
      sha256 "d24be05e109e49708c14935295663e685e3b9a5d9c8ec0f568c581c8bf8b3b5b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2301/agentshield_0.2.2301_darwin_arm64.tar.gz"
      sha256 "25de758c670cd569d3e0647ea27b365a728cad946c055134328ce7c44624ae7b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2301/agentshield_0.2.2301_linux_amd64.tar.gz"
      sha256 "5015f5eb7a343ab15666be10c5f1b344d4d7f2394ecea2a4fda042614831305b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2301/agentshield_0.2.2301_linux_arm64.tar.gz"
      sha256 "542377dd007337aee8d315d7442e4c1cdd817afe37b24bb69719634bf808bf4c"
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
