cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.915"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.915/agentshield_0.2.915_darwin_amd64.tar.gz"
      sha256 "4cdc6eb8751a69b990f55e534934d8ec53a7543afb203f215d1c5d4e6220ed67"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.915/agentshield_0.2.915_darwin_arm64.tar.gz"
      sha256 "728d107b0a06c0565e74df2b47ebe09b25a12eb05fa60fffacd9607cc5456755"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.915/agentshield_0.2.915_linux_amd64.tar.gz"
      sha256 "70d39f4b78b7269fae744d2af09f14f660512dd591313c33313ee9478c8b4b92"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.915/agentshield_0.2.915_linux_arm64.tar.gz"
      sha256 "37e56104f217f4d72950a4a091f35d106971ead4c09d1eadedc4d4e341f18400"
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
