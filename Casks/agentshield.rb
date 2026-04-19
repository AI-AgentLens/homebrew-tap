cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.647"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.647/agentshield_0.2.647_darwin_amd64.tar.gz"
      sha256 "5ba7ee8b5d72818bf1b4b9de080ac404b7ef648113d0c552a036b2fe3f88c4b3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.647/agentshield_0.2.647_darwin_arm64.tar.gz"
      sha256 "62fffee2a0e8c1fc2f64bb901c9bdeec55892db75853c7401647e75400a5217b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.647/agentshield_0.2.647_linux_amd64.tar.gz"
      sha256 "6dc9fc8bbf6c9cebfc4c1d0335a4851eb225bdff9077723d9b0795faae667832"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.647/agentshield_0.2.647_linux_arm64.tar.gz"
      sha256 "7555df3b5b11852c82781f3b84b815d94c599ae57e1e3fd8b630024ba4a9f0e4"
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
