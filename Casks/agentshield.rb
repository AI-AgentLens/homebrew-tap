cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2293"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2293/agentshield_0.2.2293_darwin_amd64.tar.gz"
      sha256 "e412fb91c5a254e47843b4fc9af716442573a6398b342fb3cc708b8ad97b39fa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2293/agentshield_0.2.2293_darwin_arm64.tar.gz"
      sha256 "8f3c50f0946d1ee79112c0949097703a9b0d9cd38d5b42b174717b2d8cbd09ce"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2293/agentshield_0.2.2293_linux_amd64.tar.gz"
      sha256 "fcd406df6f68e2c3ca8eced0baec05a32e262be1b2dda719fbe0b1999501bb15"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2293/agentshield_0.2.2293_linux_arm64.tar.gz"
      sha256 "1576a86e4bfda5d390f83bee46f4713d808e7b91709928ae1237fe44a3342c43"
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
