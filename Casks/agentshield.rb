cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1867"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1867/agentshield_0.2.1867_darwin_amd64.tar.gz"
      sha256 "d73a624ae4151888f4e003abc01439ec93a67acf13635258c90bc0f765d463f6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1867/agentshield_0.2.1867_darwin_arm64.tar.gz"
      sha256 "225072c85f48b4a1b5fbb23a69d9e109c08244c4041922b2d4f1752a3e99e126"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1867/agentshield_0.2.1867_linux_amd64.tar.gz"
      sha256 "b4a95be71c170bdd8448582b67f73d13258b16c009a71dbabeb405ccb7529abb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1867/agentshield_0.2.1867_linux_arm64.tar.gz"
      sha256 "4bbc7dc854cfa28e8d24daf2f82ec4849264b770ba65a74e3826fa2cc8a9eb4a"
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
