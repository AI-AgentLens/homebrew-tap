cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1142"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1142/agentshield_0.2.1142_darwin_amd64.tar.gz"
      sha256 "5353fc4b9dd8ff04304afc6b96adab19418551049f98b269099271f30f98db74"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1142/agentshield_0.2.1142_darwin_arm64.tar.gz"
      sha256 "1626157f8bcaeffff67e724ed9ea737635048cf571e5834cd069a49d24b03a4c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1142/agentshield_0.2.1142_linux_amd64.tar.gz"
      sha256 "901a8024ae2dfa364d1893d6bf66a5dc9edf380020e51db9d80d920d07225530"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1142/agentshield_0.2.1142_linux_arm64.tar.gz"
      sha256 "0931376135110ad1cd655ab4676ce04b19bfcd11d13b6f170b85f4a84fa15cba"
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
