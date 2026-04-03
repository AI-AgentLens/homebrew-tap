cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.353"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.353/agentshield_0.2.353_darwin_amd64.tar.gz"
      sha256 "f3647f44d767fe0fd41c07f882530ab30f8185b4b323933ebbff13589c5a7b37"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.353/agentshield_0.2.353_darwin_arm64.tar.gz"
      sha256 "56386524a8521e6d825a9056eb62e621527d39a9c3919e3ed80fd95909889731"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.353/agentshield_0.2.353_linux_amd64.tar.gz"
      sha256 "92a089144e9d35c4a6300a5ced1d29939d855b2464c115b8f0644a51b20322b8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.353/agentshield_0.2.353_linux_arm64.tar.gz"
      sha256 "2e032792bcfa660b40d09e0e8a4332e9d3cb8fb7f599736162bd29d111f57dc8"
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
