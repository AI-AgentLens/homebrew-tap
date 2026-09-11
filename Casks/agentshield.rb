cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2118"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2118/agentshield_0.2.2118_darwin_amd64.tar.gz"
      sha256 "f4cc07a5983340e78710a5ab124bb2fb610e2c0434bfb290e3e27527464a6012"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2118/agentshield_0.2.2118_darwin_arm64.tar.gz"
      sha256 "df296546a1834cce0ac2733fe8bb8b4b3e672356dd5cac777ce1c3dc029ec280"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2118/agentshield_0.2.2118_linux_amd64.tar.gz"
      sha256 "bfed30a6602eab7a33d98ef9e173fbde94941061f21c53b6d2b64d92004e0aef"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2118/agentshield_0.2.2118_linux_arm64.tar.gz"
      sha256 "05c02ee53cc5d153adfa482122442764141b67e3d898c154ea0e2bfe969fb630"
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
