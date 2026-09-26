cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2263"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2263/agentshield_0.2.2263_darwin_amd64.tar.gz"
      sha256 "92ab77762f38cc32c72832581c85a8a436057579dcb9b8e3a55c485ad4fa4481"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2263/agentshield_0.2.2263_darwin_arm64.tar.gz"
      sha256 "721627d13ccdbfdf8f57adf1c3052b33eefc59afca1b97610a4e463d774bdeb4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2263/agentshield_0.2.2263_linux_amd64.tar.gz"
      sha256 "b1706f520e2379aca0336744ab1ff55fb7cddf90e6b9050f611f1cbde5ed1ac1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2263/agentshield_0.2.2263_linux_arm64.tar.gz"
      sha256 "03b12ba39aab34467c80de0d02624cb4a073b7b53e4d7bedcfb029b7bd1330a5"
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
