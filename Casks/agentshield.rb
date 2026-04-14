cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.586"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.586/agentshield_0.2.586_darwin_amd64.tar.gz"
      sha256 "430efbe7f1ca0e058319fc11c9975cecc47830e1da08524916f6cd118b8d4594"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.586/agentshield_0.2.586_darwin_arm64.tar.gz"
      sha256 "c090ec4034a7ea58db22b12775536e7c173d44f956d8eff5b9f632cfa4172f07"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.586/agentshield_0.2.586_linux_amd64.tar.gz"
      sha256 "682169bc6cb547122d919867a43fd5882f65ca003abc787abe7519465abc2060"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.586/agentshield_0.2.586_linux_arm64.tar.gz"
      sha256 "31a2f5f8c561cc1a860ae4266c12ee4d6fbca98774d8c69f48c594aa6c9b7460"
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
