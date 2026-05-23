cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1089"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1089/agentshield_0.2.1089_darwin_amd64.tar.gz"
      sha256 "30f7254fcfe234317cbe5162e5392ffd67601b5c0482851a2e6ebf7f9186f0eb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1089/agentshield_0.2.1089_darwin_arm64.tar.gz"
      sha256 "07efb44861fbc1e74082dc21a1f4664994daa1051502124ed24a4fdafc0af399"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1089/agentshield_0.2.1089_linux_amd64.tar.gz"
      sha256 "33536ed7b6cf18e32c13d1e9cdec80147dfb7870e841ce71fb8aa2e5c20b7148"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1089/agentshield_0.2.1089_linux_arm64.tar.gz"
      sha256 "def5a6279eb5270927e98133145eaefaf2858ec232b26f5db72f81ddb883b10a"
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
