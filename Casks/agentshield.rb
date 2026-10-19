cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2468"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2468/agentshield_0.2.2468_darwin_amd64.tar.gz"
      sha256 "7314cb328a9e7c12e22395c7087d8247c6597681c30fe3e2e1f5ce7fb8fd55ce"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2468/agentshield_0.2.2468_darwin_arm64.tar.gz"
      sha256 "2b01440ae5d8096e39e15e1c2b9bca90f3ea1d11de2d1360e8c03e03eab43e44"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2468/agentshield_0.2.2468_linux_amd64.tar.gz"
      sha256 "c35e81c376fb3efd5b5897e27c3c6ec0da7a0aa76492ec493c44c9718b0c527d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2468/agentshield_0.2.2468_linux_arm64.tar.gz"
      sha256 "91dbbd1f91b070ee9e11490f2e2f2be34bbbe2d466bc08e520b7a66e6039d32c"
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
